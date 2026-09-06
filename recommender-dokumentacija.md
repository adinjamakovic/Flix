# Sistem preporuke — Flix

Dokument opisuje sistem preporuke filmova implementiran u `Flix.Backend`. Sve što je ovdje
opisano odgovara kodu u
[`Flix.Services/Recommendations/`](Flix.Backend/Flix.Services/Recommendations/),
[`UserRecommendationService.cs`](Flix.Backend/Flix.Services/Implementations/UserRecommendationService.cs)
i [`MovieRecommendationsController.cs`](Flix.Backend/Flix.WebApi/Controllers/MovieRecommendationsController.cs).

## Pregled

Prijava teme opisuje **hibridni** pristup: content-based profil nad atributima filmova koje je
korisnik pozitivno označio, spojen s **user-based** collaborative filteringom nad korisnicima
sličnih preferencija. To je jedini model u sistemu i on je ono što aplikacija poziva.

Dva sloja:

1. **Signali** ([`Recommendations/`](Flix.Backend/Flix.Services/Recommendations/)). Jedno mjesto
   koje zna šta se broji kao interes i koliko koji signal vrijedi.
2. **Hibrid** ([`HybridRecommender`](Flix.Backend/Flix.Services/Recommendations/HybridRecommender.cs)).
   Content-based profil × user-based collaborative filtering, računato **pri svakom pozivu**.
   Namjerno čist kod — bez baze, sata i slučajnosti — pa se može testirati sam za sebe;
   `UserRecommendationService` je samo EF i mapiranje oko njega.

Ako korisnik nema nijedan pozitivan signal, vraća se lista popularnih filmova.

Ništa se ne precomputa, ne trenira u pozadini i ne sprema u tabelu. Ranija verzija sistema je
imala i film–film model (ML.NET one-class matrična faktorizacija u tabelu `MovieRecommendations`,
worker svakih 30 minuta); uklonjen je jer ga nijedan klijent nije pozivao, jer mu opaženi parovi
nisu nosili `Label` (pa ih je trener povlačio isto kao ćelije koje niko nije dotakao), i jer
prijava teme opisuje samo hibrid. Migracija `DropMovieRecommendations` briše tabelu, a paketi
`Microsoft.ML` i `Microsoft.ML.Recommender` više nisu zavisnosti.

## Signali

`RecommendationSignalService` svodi tri tabele na jedan tip:

```csharp
UserMovieSignal(int UserId, int MovieId, float Affinity, bool IsWatched)
```

`Affinity` je jačina interesa i vodi bodovanje; `IsWatched` govori je li korisnik film već
odgledao i vodi isključivanje. Nezavisni su: recenzija s jednom zvjezdicom je odgledana bez
afiniteta, a film na watchlisti je afinitet bez gledanja.

Jačine su one iz prijave teme
([`RecommendationSignalWeights`](Flix.Backend/Flix.Services/Recommendations/RecommendationSignalWeights.cs)):

| Signal | Izvor | Uslov | Jačina | `Affinity` |
| --- | --- | --- | --- | --- |
| Ocjena | `Reviews` | `Rating >= 3.0` | visoka | `1.0` |
| „Sviđa mi se" | `Reviews` | `IsLiked == true` | srednja | `0.6` |
| Watchlist | `MovieListItems` | lista je tipa `Watchlist` | srednja | `0.6` |
| Evidentirano gledanje bez ocjene | `Activities` / `Reviews` | `WatchedMovie` ili recenzija bez ocjene | niska | `0.25` |

Dva pravila drže tabelu na okupu:

- **Signali se ne sabiraju.** Za par `(korisnik, film)` vrijedi najjači signal. Isti film ocijenjen,
  lajkan i stavljen na watchlistu je i dalje `1.0`, a ne `1.85` — to su tri čitanja istog interesa,
  ne tri glasa.
- **Najslabiji signal vrijedi samo bez ocjene.** Čim ocjena postoji, ona je već rekla sve što bi
  gledanje reklo, u oba smjera. Zato ocjena ispod `3.0` ostaje `Affinity = 0`, a `IsWatched = true`.

Kompletno pravilo je u [`RecommendationSignalBuilder`](Flix.Backend/Flix.Services/Recommendations/RecommendationSignalBuilder.cs);
izlaz je sortiran po `(UserId, MovieId)`, pa je sve nizvodno determinističko.

## Lista za korisnika (hibrid)

`GET /MovieRecommendations/GetRecommendationsForUser` (korisnik se čita iz tokena, ne iz upita).
To je jedini endpoint sistema preporuke i jedini koji mobilna aplikacija poziva.

### Kandidati i isključivanja

Kandidati su svi `IsEnabled` filmovi umanjeni za sve za koje korisnik ima signal (odgledani ili
već stavljeni u red). Preporuka ima smisla samo ako je otkriće.

Onemogućeni filmovi i dalje **grade** profil i i dalje se broje u ukusu susjeda, ali se nikad ne
**preporučuju**.

### Content-based komponenta

Svaki film se svodi na rijedak vektor tokena
([`MovieFeatures`](Flix.Backend/Flix.Services/Recommendations/MovieFeatures.cs)):

| Token | Težina |
| --- | --- |
| `genre:{id}` | `1.0` |
| `director:{id}` | `0.9` |
| `actor:{id}` (prvih 8 po redoslijedu pojavljivanja) | `0.5` |
| `studio:{id}` | `0.4` |
| `decade:{godina/10}` | `0.3` |
| `country:{id}` | `0.25` |
| `language:{id}` | `0.25` |

Žanr i režiser razdvajaju filmove daleko bolje nego zemlja snimanja, pa vrijede više. Vektor se
zatim normalizuje na jediničnu dužinu, čime skalarni proizvod postaje kosinusna sličnost — film s
dugačkom glumačkom postavom ne može nadglasati oskudno opisan film samom količinom tokena.

Profil korisnika je zbir `Affinity × vektor` po svim filmovima za koje ima pozitivan signal,
ponovo normalizovan. Content-score kandidata je kosinus između profila i kandidatovog vektora.

### Collaborative komponenta (user-based)

1. Svaki korisnik je vektor `film → Affinity` (samo pozitivni signali).
2. Kosinusna sličnost između ciljnog korisnika i svakog drugog. Traži se **najmanje 2 zajednička
   filma** — jedan zajednički film je slučajnost, ne zajednički ukus.
3. Uzima se **30 najsličnijih** susjeda (izjednačeni po `UserId`, radi determinizma).
4. Bodovanje kandidata je **skupljeni** (*shrunk*) ponderisani prosjek:

   ```
   collab(film) = Σ (sličnost × afinitet susjeda) / (Σ sličnost + 1.0)
   ```

   Konstanta u nazivniku spušta filmove koje podržava jedan slab susjed; rezultat ostaje u `[0, 1]`,
   dakle u istom rasponu kao kosinus s content strane.

### Miješanje

```
w = 0.6 × min(1, brojSusjeda / 5)
score = w × collab + (1 − w) × content
```

Težina nije fiksna. Korisnik bez ijednog susjeda dobija **čisto content-based** listu, a
collaborative polovina preuzima tek kad ih ima dovoljno da njihovo slaganje išta znači. Maksimum
je `0.6`, pa profil nikad ne nestane iz računa.

Kandidati sa `score <= 0` ispadaju. Sortira se opadajuće po score-u, izjednačeni po `MovieId`, i
uzima se **12**.

### Objašnjenja

Polovina koja je više doprinijela dobija pravo da objasni preporuku:

| Slučaj | `Source` | `Reason` | `Movie` / `MovieId` |
| --- | --- | --- | --- |
| collaborative jači | `Similar` | `"Loved by users with taste like yours"` | prazno |
| content jači | `Similar` | `"Because you liked {naslov}"` | seed film |
| dopuna / nema signala | `Popular` | `"Popular on Flix right now"` | prazno |

Seed film je onaj iz korisnikovog profila s najvećim `Affinity × sličnost` prema kandidatu —
dakle film koji kandidata najbolje objašnjava, a ne naprosto zadnji ocijenjeni.

Mobilna aplikacija ([`movie_list.dart`](Flix.UI/flix_mobile/lib/screens/home/movie_list.dart))
mapira `Reason` po `recommendedMovie.id` i prosljeđuje ga `MovieSideScroll`-u kao `captionOf`, pa
se tekst prikazuje ispod postera u redu "Recommended for you".

### Popularni filmovi (fallback i dopuna)

Korisnik bez ijednog pozitivnog signala nema ni profil ni susjede, pa `Recommend` vraća praznu
listu i lista se puni popularnošću. Isto se koristi kao **dopuna** kad hibrid vrati manje od 12
filmova — poluprazan red na početnom ekranu izgleda kao greška, a ne kao kratka lista.

Popularnost je skupljena, ne prosta suma ni prosjek:

```
popularity(film) = Σ afinitet / (brojKorisnika + 2.0)
```

Tako jedna petica ne može nadjačati film koji je pedeset ljudi voljelo. Izjednačeni se razdvajaju
po `Views` opadajuće, pa po `Id` — čime film koji niko još nije dotakao i dalje ulazi u listu, što
je korisniku koji je prošao ostatak kataloga jedino što je preostalo.

## Performanse

Lista se računa pri svakom pozivu i **ne kešira se** — ocjena upisana prije sekunde mora pomjeriti
listu. Po pozivu idu tri upita za signale (recenzije, watchlist, aktivnosti gledanja), jedan za
kandidate, jedan projektovani upit za atribute filmova i jedan `Include` upit za filmove koji
zaista izlaze. Atributi se čitaju projekcijom, a ne `Include`-om, jer profilu trebaju samo id-evi.

Ako katalog ili broj korisnika naraste toliko da to postane usko grlo, prvo mjesto za keš je
susjedstvo (`FindNeighbours`), jer je jedino kvadratno po korisnicima; content profil i bodovanje
kandidata su linearni.

## Onemogućeni filmovi

Model **uči** iz onemogućenih filmova, jer takav film i dalje nosi signal o filmovima oko sebe.
Ali se nijedan ne **preporučuje**: hibrid ih ne uzima u kandidate, a fallback lista popularnih
filtrira po istom polju.

Endpoint zahtijeva token (`[Authorize]` na kontroleru). Sistem preporuke nema nijednu admin
operaciju — nema šta da se generiše ni briše.

## Testovi

`Flix.Services.Tests` (xUnit, u `.slnx`, pokreće se sa `dotnet test`). Testira se čisti dio —
signali i hibrid:

| Test | Šta tvrdi |
| --- | --- |
| `ContentBasedRankingPutsAMovieSharingGenreAndDirectorAboveAnUnrelatedOne` | kandidat s istim žanrom i režiserom kao voljeni film dobija viši score od nepovezanog |
| `CollaborativeRankingPutsACloseNeighboursPickAboveADistantNeighboursPick` | bez ijednog zajedničkog atributa, film bližeg susjeda dobija viši score |
| `AUserSharingASingleMovieIsNotANeighbour` | prag od dva zajednička filma |
| `AUserWithNoSignalsGetsNothingFromTheHybrid` | hibrid bez profila ne izmišlja listu |
| `PopularityRankingPrefersManyLikesOverASingleStrongOne` | skupljena popularnost |
| `EachSignalCarriesTheStrengthTheSpecificationGivesIt` | tabela jačina iz prijave |
| `ARatingBelowTheThresholdIsWatchedWithoutAffinity` | ocjena ispod praga → `Affinity = 0`, `IsWatched = true` |
| `AWatchlistEntryIsAffinityWithoutHavingBeenWatched` | obrnut slučaj |
| `SignalsForOnePairDoNotAddUp` | najjači signal pobjeđuje |
| `APoorlyRatedMovieContributesNothingToTheProfile` | loše ocijenjen film ne ulazi u profil |

## Konstante

| Konstanta | Vrijednost | Gdje | Značenje |
| --- | --- | --- | --- |
| `MinimumPositiveRating` | `3.0` | `RecommendationSignalWeights` | prag pozitivne ocjene |
| `Rated` / `Liked` / `Watchlisted` / `Watched` | `1.0` / `0.6` / `0.6` / `0.25` | `RecommendationSignalWeights` | jačine signala |
| `MaxCollaborativeWeight` | `0.6` | `HybridRecommender` | gornja granica collaborative polovine |
| `NeighboursForFullWeight` | `5` | `HybridRecommender` | koliko susjeda do pune težine |
| `MaxNeighbours` | `30` | `HybridRecommender` | veličina susjedstva |
| `MinimumSharedMovies` | `2` | `HybridRecommender` | prag da se neko uopšte broji kao susjed |
| `NeighbourShrinkage` | `1.0` | `HybridRecommender` | skupljanje ponderisanog prosjeka |
| `PopularityShrinkage` | `2.0` | `HybridRecommender` | skupljanje popularnosti |
| `RecommendationCount` | `12` | `UserRecommendationService` | dužina korisničke liste |
| `BilledActorLimit` | `8` | `MovieFeatures` | koliko glumaca ulazi u vektor |
