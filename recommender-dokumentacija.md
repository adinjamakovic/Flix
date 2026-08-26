# Sistem preporuke — Flix

Dokument opisuje sistem preporuke filmova implementiran u `Flix.Backend`. Sve što je ovdje
opisano odgovara kodu u
[`MovieRecommendationService.cs`](Flix.Backend/Flix.Services/Implementations/MovieRecommendationService.cs),
[`MovieRecommendationWorkerService.cs`](Flix.Backend/Flix.Services/BackgroundServices/MovieRecommendationWorkerService.cs)
i [`MovieRecommendationsController.cs`](Flix.Backend/Flix.WebApi/Controllers/MovieRecommendationsController.cs).

## Pregled

Sistem se sastoji od dva sloja koja dijele isti model:

1. **Model film–film** ("slično ovome"). ML.NET one-class matrična faktorizacija nad parovima
   filmova koje je isti korisnik pozitivno označio. Trenira se u pozadini i rezultat se sprema u
   tabelu `MovieRecommendations`.
2. **Lista za korisnika** ("Recommended for you"). Nema zaseban model — bira nekoliko filmova
   koje je korisnik nedavno volio (*seed* filmovi), čita njihove spremljene preporuke, izbacuje
   sve što je korisnik već vidio i objašnjava svaku preporuku seed filmom iz kojeg je nastala.

Ako korisnik nema nijedan pozitivan signal, ili ako filtriranje ne ostavi ništa, vraća se lista
popularnih filmova.

## Signali

Model uči isključivo iz **pozitivnih** signala. `BuildTrainingData` skuplja dvije vrste, obje
svedene na jedinstven par `(korisnik, film)`:

| Signal | Izvor | Uslov |
| --- | --- | --- |
| Pozitivna recenzija | `Reviews` | `IsLiked == true` **ili** `Rating >= 3.0` |
| Watchlist | `MovieListItems` | lista je tipa `Watchlist` |

Namjerno **nije** signal za treniranje:

- ocjena ispod 3.0 — film je odgledan, ali nije indikacija da se sličan treba preporučiti;
- aktivnost `WatchedMovie` — govori samo da je film viđen, a to se koristi za isključivanje
  (vidi *Isključivanja*), ne za učenje.

Signali se ne sabiraju i ne teže se različito. Za model je par `(korisnik, film)` prisutan ili nije.

## Model

### Građenje skupa za treniranje

Signali se grupišu po korisniku. Korisnici s manje od dva različita filma se preskaču — jedan
film ne pravi nijedan par. Za svakog preostalog korisnika emituje se **svaki neuređeni par**
njegovih filmova, i to u oba smjera (`A → B` i `B → A`), pa je matrica ko-pojavljivanja
simetrična i "slično ovome" radi jednako bez obzira s koje strane se gleda.

Korisnik s *n* filmova doprinosi `n * (n - 1)` redova, pa skup raste kvadratno po aktivnom korisniku.

### Mapiranje na guste indekse

Trener indeksira matricu **po poziciji**, ne po vrijednosti ključa. Zato se `Movie.Id` prije
treniranja preslikava na gust raspon `0..n-1` (`matrixIndexByMovieId`), a obje ključne kolone se
kroz `SchemaDefinition` deklarišu kao `KeyDataViewType` veličine jednake broju filmova u katalogu.
Bez toga bi svaki id veći ili jednak veličini kolone bio izvan raspona, a takav ključ daje `NaN`,
što SQL Server odbija kao nevažeću vrijednost za `real`.

### Trener

`Microsoft.ML.Recommender`, `MatrixFactorizationTrainer` sa sljedećim opcijama:

| Opcija | Vrijednost |
| --- | --- |
| `MatrixColumnIndexColumnName` | `MovieId` |
| `MatrixRowIndexColumnName` | `CoReviewMovieId` |
| `LossFunction` | `SquareLossOneClass` |
| `Alpha` | `0.01` |
| `Lambda` | `0.025` |
| `NumberOfIterations` | `100` |
| `C` | `0.00001` |

`SquareLossOneClass` je izbor za **implicitni feedback**: nema ocjena para, nego samo činjenica da
se par pojavio. Kolona `Label` postoji jer je trener traži, ali ne nosi ocjenu — one-class varijanta
svaki proslijeđeni par tretira kao opaženi pozitivan, a svaku neopaženu ćeliju matrice kao konstantu
`C` s težinom `Alpha`. Otuda male vrijednosti: neopažen par nije negativan primjer, samo slabo
kažnjen.

Treniranje se prekida bez ikakve izmjene ako katalog ima manje od dva filma ili ako nema nijednog
para (`data.Count == 0`).

### Spremanje rezultata

Za svaki film u katalogu model ocijeni svaki drugi film, neizračunljive rezultate
(`!float.IsFinite`) odbacuje, sortira opadajuće i sprema **top 10** kao redove
`MovieRecommendation { MovieId, RecommendedMovieId, Score }`.

Spremaju se i onemogućeni filmovi — oni i dalje nose signal ko-pojavljivanja, a filtriranje se
radi pri čitanju (vidi *Onemogućeni filmovi*).

Svako pokretanje proizvodi kompletan set za cijeli katalog, pa se prethodni redovi prvo brišu
(`ExecuteDeleteAsync`). Brisanje i upis dijele jednu transakciju — neuspio upis ne smije ostaviti
tabelu praznu.

### Kada se trenira

- `MovieRecommendationWorkerService` — `BackgroundService` registrovan u `Program.cs`. Generiše
  odmah pri pokretanju API-ja i zatim **svakih 30 minuta**. Svaki izuzetak se loguje i petlja se
  nastavlja, tako da neuspjelo generisanje ne ruši host.
- `POST /MovieRecommendations/GenerateRecommendations` — ručno, samo admin.
- `DELETE /MovieRecommendations/DeleteRecommendations` — briše sve spremljene preporuke, samo admin.

## Lista za korisnika

`GET /MovieRecommendations/GetRecommendationsForUser` (korisnik se čita iz tokena, ne iz upita).

### Isključivanja

Prije svega ostalog gradi se skup filmova koje korisnik **već zna** — unija tri izvora:

- svi filmovi koje je recenzirao (bez obzira na ocjenu),
- svi filmovi na njegovom watchlistu,
- svi filmovi iz aktivnosti tipa `WatchedMovie`.

Preporuka ima smisla samo ako je otkriće, pa u skupu završe i sami seed filmovi — model povezuje
ko-pojavljene filmove u oba smjera, pa bi se seed inače vratio kao preporuka samom sebi.

### Seed filmovi

Uzimaju se do **3** filma koje je korisnik recenzirao s ocjenom `>= 3.0` ili označio kao voljene,
najskorija recenzija prva. Grupiše se po filmu prije uzimanja, jer bi inače ponovno gledanje istog
filma zauzelo dva od tri mjesta.

Ako nema nijednog takvog filma → *popularni filmovi*.

### Sastavljanje liste

Za svaki seed se čita njegovih spremljenih 10 preporuka — sve, a ne samo šest koliko ih treba,
jer isključivanja obično pokose većinu seta: filmovi najbliži onome što je korisnik volio su
upravo oni koje je najvjerovatnije već gledao. Iz svakog seta se zadržava **najviše 6** filmova
koji nisu isključeni i nisu već dodati iz nekog ranijeg seed-a (deduplikacija ide po
`RecommendedMovieId`, jer su odgovori zasebni objekti). Maksimum liste je time 18 filmova.

Ako nakon svega lista ostane prazna → *popularni filmovi*.

### Objašnjenja

Svaka zadržana preporuka nosi seed film iz kojeg je nastala:

- `Movie` / `MovieId` — seed film (s razriješenim SAS URL-ovima za slike),
- `Reason` — `"Because you liked {naslov seed filma}"`,
- `Source` — `Similar`.

Mobilna aplikacija ([`movie_list.dart`](Flix.UI/flix_mobile/lib/screens/home/movie_list.dart))
mapira `Reason` po `recommendedMovie.id` i prosljeđuje ga `MovieSideScroll`-u kao `captionOf`, pa
se tekst prikazuje ispod postera u redu "Recommended for you".

## Popularni filmovi (fallback)

Rangira se po broju **različitih korisnika** koji su film pozitivno dotakli — jedinstveni parovi
`(korisnik, film)` iz recenzija i watchlista, samo za filmove koji su `IsEnabled` i nisu već viđeni.
Sortira se opadajuće po tom broju, izjednačeni po `Id`, i uzima se 10.

Ako ih se skupi manje od 10, lista se dopunjuje filmovima koje niko još nije dotakao, sortiranim
po `Views` opadajuće. Takav film nema signal po kojem bi se rangirao, ali je i dalje neviđen i
dalje vrijedan ponude — a korisniku koji je prošao ostatak kataloga je jedino što je preostalo.

Ove stavke nemaju seed: `MovieId` i `Movie` su prazni, `Source` je `Popular`, a `Reason` je
`"Popular on Flix right now"`.

## Preporuke za pojedini film

`GET /MovieRecommendations/GetRecommendationsForMovies?MovieId={id}&NumberOfRecommendations={n}`
(podrazumijevano 10) čita spremljene redove za taj film sortirane po `Score` opadajuće. Ovdje se
ništa ne računa u trenutku poziva; jedini filter je `IsEnabled` na preporučenom filmu. Polje `Movie`
ostaje prazno jer se učitava samo `RecommendedMovie`.

## Onemogućeni filmovi

Model **uči** iz onemogućenih filmova — skup za treniranje i indeks matrice se grade nad svim
redovima u `Movies`, jer onemogućen film i dalje nosi signal ko-pojavljivanja o filmovima oko sebe.
Ali se nijedan takav film ne **preporučuje**: `GetRecommendationsForMovieAsync` traži
`RecommendedMovie.IsEnabled`, pa filter važi i za "slično ovome" i za korisničku listu, koja te iste
redove čita. Fallback lista popularnih filtrira po istom polju.

Filtrira se pri čitanju, a ne pri spremanju, da bi ponovno omogućen film odmah bio dostupan, bez
čekanja na sljedeći prolaz workera.

Oba `GET` endpointa zahtijevaju token (`[Authorize]` na kontroleru); oba `Generate` / `Delete`
dodatno traže rolu `Admin`.

## Konstante

Sve su na vrhu `MovieRecommendationService`, osim intervala workera:

| Konstanta | Vrijednost | Značenje |
| --- | --- | --- |
| `MinimumPositiveRating` | `3.0` | prag pozitivne ocjene |
| `RecommendationsPerMovie` | `10` | koliko se preporuka sprema po filmu |
| `SeedMoviesPerUser` | `3` | koliko seed filmova ulazi u korisničku listu |
| `RecommendationsPerSeed` | `6` | koliko preporuka po seed-u preživi filtriranje |
| `PopularFallbackCount` | `10` | dužina fallback liste |
| `Interval` (worker) | `30 min` | period ponovnog treniranja |
