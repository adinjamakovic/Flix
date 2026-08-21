# Flix

**English below — [skoči na englesku verziju](#english) / [jump to the English version](#english)**

Platforma za katalog filmova po uzoru na Letterboxd: ASP.NET Core API, Flutter desktop klijent
za administraciju kataloga i Flutter mobilni klijent za pregled filmova, ocjenjivanje, vođenje
dnevnika i pravljenje lista.

## Struktura repozitorija

| Putanja | Šta sadrži |
| --- | --- |
| `Flix.Backend/` | ASP.NET Core 10 Web API na SQL Serveru, slike u Azure Blob Storage-u. Četiri slojevita projekta: `Flix.Model` → `Flix.CommonServices` → `Flix.Services` → `Flix.WebApi`. |
| `Flix.UI/flix_desktop/` | Flutter desktop admin klijent — filmovi, glumci, korisnici, recenzije i clashevi, potpuni CRUD. |
| `Flix.UI/flix_mobile/` | Flutter mobilni klijent — feedovi na početnoj, pretraga, detalji filma, profil, dnevnik, watchlist, liste, zahtjevi za filmove, prijave grešaka u katalogu. |
| `docker-compose.yml` | SQL Server + RabbitMQ + API. |

## Pokretanje

### Sve u Dockeru

```powershell
docker compose up -d --build
```

Time se podiže SQL Server na `localhost:1433` (`sa` / `YourStrong!Passw0rd1`), RabbitMQ na
`localhost:5672` sa management UI-jem na [localhost:15672](http://localhost:15672)
(`admin` / `admin`) i API na `http://localhost:5071`. API čeka SQL Serverov healthcheck i sam
primjenjuje migracije pri pokretanju, pa se na svježem volumenu baza podiže već popunjena.

Za pokretanje samo baze i RabbitMQ-a, kada se API pokreće iz IDE-a:

```powershell
docker compose up -d sqlserver rabbitmq
```

### API iz IDE-a

```powershell
dotnet run --project Flix.Backend/Flix.WebApi --launch-profile https   # https://localhost:7140
dotnet dev-certs https --trust
```

`Flix.WebApi/.env` mora postojati sa `BLOB_STORAGE_CONNECTION_STRING=…` (kopirati
`.env_example`) — `Program.cs` ga učitava pri pokretanju i bez njega pada svaki odgovor koji
nosi URL slike.

U Development okruženju API se sam dokumentuje na `/scalar`, a OpenAPI dokument stoji na
`/openapi/v1.json`.

### Flutter klijenti

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows          # desktop
flutter run                     # mobilni, na emulatoru ili uređaju
```

`*.g.dart` je u gitignore-u, pa `build_runner` nije opcionalan na svježem klonu — nijedan
klijent se bez njega ne kompajlira.

Bazni URL API-ja je konstanta koja se postavlja pri kompajliranju: desktop klijent
podrazumijeva `https://localhost:7140/`, a mobilni `http://10.0.2.2:5071/` (put Android
emulatora do host mašine). Za pokretanje na stvarnom uređaju proslijediti
`flutter run --dart-define=BASE_URL=http://192.168.1.10:5071/`.

### Nalozi iz seed podataka

| Korisničko ime | Lozinka | Uloga |
| --- | --- | --- |
| `adin.jamakovic` | `Admin123!` | Admin |
| `emmaclarke` | `Test123!` | User |

Desktop klijent je samo za administratore — čita role claim iz JWT-a i odbija sve ostale već na
login ekranu.

## Recenzije, dnevnik i ponovna gledanja

Sve što korisnik zabilježi o filmu — ocjenu, lajk, napisanu recenziju, gledanje — jeste red u
tabeli **`Reviews`**. Dvije vrste redova razdvaja flag `IsDiaryEntry`, i ta razlika je ono što
treba razumjeti prije diranja ovog dijela aplikacije.

<img src="Flix.UI/ReviewScreen.png" alt="Action sheet na detaljima filma" width="320">

Obje vrste se upisuju sa ekrana detalja filma. Dugme
`"Rate, log, review, add to list + more"` otvara action sheet sa slike
(`screens/movie_details/actions_sheet.dart`), a odatle:

**Toggleovi i zvjezdice mijenjaju trenutni stav korisnika** (`IsDiaryEntry = false`). *Watch*,
*Like* i ocjena zvjezdicama ažuriraju jedan jedini red po korisniku i filmu, na mjestu.
Ponovno ocjenjivanje filma zamjenjuje prethodnu ocjenu; ne dodaje ništa novo. Iz tog reda se
čita stanje "ovo si već ocijenio" na ekranu detalja — a kada trajne recenzije nema, jer je
prerasla u zapis, čita se iz posljednjeg zapisa u dnevniku. Tako korisnika po filmu uvijek
predstavlja tačno jedan red, i tim redom upravljaju i zvjezdice i forma za bilježenje.

**"Review or log…" upisuje zapis u dnevnik** (`IsDiaryEntry = true`). Otvara formu za tekst
recenzije i datum gledanja filma; potvrda dodaje novi red. Korisnik isti film može zabilježiti
proizvoljan broj puta — svaki zapis je jedno gledanje, a svaki nakon prvog je ponovno gledanje
(`IsRewatch`). To je jedini način da se dobije više od jedne recenzije istog filma, zbog čega
se dnevnik čita kao hronologija, a ne kao spisak mišljenja.

Zapis ne dodaje uvijek novi red. Ako film već ima trajnu recenziju — korisnik ga je ocijenio
zvjezdicama, ali ga još nije zabilježio — taj red **postaje** zapis (`IsDiaryEntry` prelazi na
`true`, uz tekst i datum). Ocjena data u sheetu je početak iste recenzije, a ne druge, pa iza
ocjenjivanja i bilježenja stoji jedan red. Tek ponovno gledanje dodaje novi, zbog čega drugi
red uvijek znači i drugo gledanje.

**"Watchlist" uopšte nije recenzija.** Dodaje `MovieListItems` red u korisnikovu watchlistu, uz
ostale njegove liste.

Dvije vrste se i čitaju odvojeno: `GET /Diary` vraća samo `IsDiaryEntry` redove jednog
korisnika, od najnovijeg, dok `/Review` služi trajne recenzije iza ocjena, brojača i feeda
prijatelja.

Ta razlika pokreće i preporuke. `IRecommendationSignalService` skuplja recenzije, stavke
watchliste i aktivnosti gledanja u jedan `UserMovieSignal` po korisniku i filmu, gdje su
naklonost i to da je film odgledan nezavisni: recenzija od jedne zvjezdice je odgledan film bez
naklonosti, a dodavanje na watchlistu je naklonost prema filmu koji još nije pogledan.

### Trenutno stanje

Tok je povezan s kraja na kraj. Toggleovi i zvjezdice pišu kroz
`POST /Review/StandingReview`, a `GET /Review/MovieState` vraća stanje na kojem se sheet
otvara — odgledano, lajk, ocjena, watchlista i broj zapisa u dnevniku. *Review or log…*
otvara formu (`screens/movie_details/log_form.dart`) koja piše na `POST /Diary`; `Review`
sada nosi `WatchedOn`, pa se dnevnik sortira po danu gledanja, a ne po vremenu upisa.
`IsRewatch` odlučuje server, jer je svaki zapis nakon prvog gledanja ponovno gledanje.
*Watchlist* ide na `POST /List/AddToList` i `DELETE /List/Watchlist/{movieId}`, i zapis u
dnevnik sam skida film sa watchliste.

*Add to a list…* otvara sheet sa korisnikovim custom listama
(`screens/movie_details/add_to_list_sheet.dart`) — watchlista se tu ne bira jer je toggle
iznad, a clash liste pripadaju clashu. Dodavanje ide na `POST /List/AddToList`, koji je
zamijenio raniji `POST /List/Watchlist/{movieId}`: jedan zahtjev pokriva obje destinacije, gdje
`ListId` nosi samo custom lista, watchlista se razrješava iz tokena i jedina piše aktivnost.
Custom lista odbija duplikat, dok ga watchlista tiho ignoriše.

*Report an issue…* otvara formu (`screens/movie_details/report_issue.dart`) — padajuća lista
tipičnih grešaka u katalogu plus opis, koji je obavezan samo uz *Other*, jer je tada jedino
što adminu govori šta da ispravi. Prijava ide na `POST /MovieIssueReport` kao `Open`;
`MovieIssueReportService` sam upisuje prijavitelja iz tokena, a `GetDataSource` onome ko nije
admin vraća samo njegove prijave, pa i listanje i izmjena i brisanje ostaju u okviru vlastitih.
Vlasnik svoju prijavu može mijenjati samo dok je otvorena; admin je zatvara `PUT`-om sa
statusom i komentarom, čime se bilježi ko ju je i kada riješio.

Ekrana za pregled prijava još nema — ni spiska poslanih prijava na mobilnom, ni admin ekrana na
desktopu — pa se prijave zasad samo šalju.

## Napomene

- `MovieRequestService` objavljuje `MovieRequested` poruku na RabbitMQ kada korisnik zatraži
  film. Ništa se na nju još ne pretplaćuje.
- Svi seed podaci stoje u `HasData` u `Flix.Services/Database/FlixSeeder.cs`, pa svaka izmjena
  seed podataka zahtijeva novu migraciju.
- Ne postoji test projekat za backend.

---

<a id="english"></a>

# Flix (English)

A movie-catalog platform in the shape of Letterboxd: an ASP.NET Core API with a Flutter
admin client for managing the catalog and a Flutter mobile client for browsing it, rating
films, keeping a diary and building lists.

## Repository layout

| Path | What it is |
| --- | --- |
| `Flix.Backend/` | ASP.NET Core 10 Web API on SQL Server, images in Azure Blob Storage. Four layered projects: `Flix.Model` → `Flix.CommonServices` → `Flix.Services` → `Flix.WebApi`. |
| `Flix.UI/flix_desktop/` | Flutter desktop admin client — movies, cast, users, reviews and clashes, full CRUD. |
| `Flix.UI/flix_mobile/` | Flutter mobile client — home feeds, search, movie details, profile, diary, watchlist, lists, movie requests, catalog issue reports. |
| `docker-compose.yml` | SQL Server + RabbitMQ + the API. |

## Running it

### Everything in Docker

```powershell
docker compose up -d --build
```

That brings up SQL Server on `localhost:1433` (`sa` / `YourStrong!Passw0rd1`), RabbitMQ on
`localhost:5672` with its management UI on [localhost:15672](http://localhost:15672)
(`admin` / `admin`), and the API on `http://localhost:5071`. The API waits on SQL Server's
healthcheck and applies migrations itself on startup, so a fresh volume comes up seeded.

To run only the database and RabbitMQ, with the API started from the IDE:

```powershell
docker compose up -d sqlserver rabbitmq
```

### The API from the IDE

```powershell
dotnet run --project Flix.Backend/Flix.WebApi --launch-profile https   # https://localhost:7140
dotnet dev-certs https --trust
```

`Flix.WebApi/.env` must exist with `BLOB_STORAGE_CONNECTION_STRING=…` (copy `.env_example`) —
`Program.cs` loads it at startup and every response carrying an image URL fails without it.

In Development the API documents itself at `/scalar`, with the OpenAPI doc at `/openapi/v1.json`.

### The Flutter clients

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows          # desktop
flutter run                     # mobile, on an emulator or device
```

`*.g.dart` is gitignored, so `build_runner` is not optional on a fresh clone — neither client
compiles without it.

The API base URL is a compile-time constant: the desktop client defaults to
`https://localhost:7140/`, the mobile client to `http://10.0.2.2:5071/` (the Android
emulator's route to the host). Override with
`flutter run --dart-define=BASE_URL=http://192.168.1.10:5071/` when running on a real device.

### Seeded logins

| Username | Password | Role |
| --- | --- | --- |
| `adin.jamakovic` | `Admin123!` | Admin |
| `emmaclarke` | `Test123!` | User |

The desktop client is admin-only — it reads the role claim out of the JWT and turns non-admins
away at the login screen.

## Reviews, the diary and rewatches

Everything a user records about a film — a rating, a like, a written review, a viewing — is a
row in the **`Reviews`** table. What separates the two kinds of row is the `IsDiaryEntry` flag,
and the distinction is the thing to understand before touching this part of the app.

<img src="Flix.UI/ReviewScreen.png" alt="The movie actions sheet" width="320">

Both kinds are written from the movie details screen. The
`"Rate, log, review, add to list + more"` button opens the actions sheet above
(`screens/movie_details/actions_sheet.dart`), and from there:

**The toggles and the stars edit the user's standing opinion** (`IsDiaryEntry = false`).
*Watch*, *Like* and the star rating update a single row per user and movie, in place. Rating a
film a second time replaces the first rating; it does not add anything. This row is what the
"you rated this" state on the details screen is read from — and when there is no standing
review, because it grew into a diary entry, that state comes from the newest entry instead.
Exactly one row per user and movie speaks for them either way, and both the stars and the log
form write to it.

**"Review or log…" writes a diary entry** (`IsDiaryEntry = true`). It opens a form for the
review text and the date the film was watched; confirming it appends a new row. A user can log
the same film any number of times — each entry is one viewing, and every entry after the first
is a rewatch (`IsRewatch`). This is the only way to end up with more than one review of a film,
which is why the diary reads as a timeline rather than a list of opinions.

An entry does not always append a row. If the film already carries a standing review — the user
rated it with the stars but never logged it — that row **becomes** the entry (`IsDiaryEntry`
flips to `true`, along with the text and the date). A rating given in the sheet is the start of
the same review rather than a different one, so rating and then logging leaves one row behind,
not two. Only a rewatch adds another, which is what makes a second row mean a second viewing.

**"Watchlist" is not a review at all.** It adds a `MovieListItems` row to the user's watchlist,
alongside their other lists.

The two kinds are read back separately: `GET /Diary` returns only `IsDiaryEntry` rows for one
user, newest first, while `/Review` serves the standing reviews behind ratings, counts and the
friends feed.

The distinction also drives recommendations. `IRecommendationSignalService` reads reviews,
watchlist items and watch activities into a single `UserMovieSignal` per user and movie, where
affinity and having-watched are independent: a one-star review is a watched film with no
affinity, a watchlist add is affinity for a film not yet seen.

### Status

The flow is wired end to end. The toggles and the stars write through
`POST /Review/StandingReview`, and `GET /Review/MovieState` returns the state the sheet opens
on — watched, liked, rated, on the watchlist, and how many diary entries the movie already
has. *Review or log…* opens a form (`screens/movie_details/log_form.dart`) that writes to
`POST /Diary`; `Review` now carries a `WatchedOn`, so the diary is ordered by the day of the
viewing rather than by the moment the entry was written. `IsRewatch` is decided by the server,
because every entry after the first viewing is one. *Watchlist* goes to
`POST /List/AddToList` and `DELETE /List/Watchlist/{movieId}`, and logging a movie takes it off
the watchlist by itself.

*Add to a list…* opens a sheet over the user's custom lists
(`screens/movie_details/add_to_list_sheet.dart`) — the watchlist is not among them because it
is the toggle above, and clash lists belong to their clash. The write goes to
`POST /List/AddToList`, which replaced the older `POST /List/Watchlist/{movieId}`: one request
covers both destinations, with `ListId` carried only by a custom list, the watchlist resolved
from the token and the only one of the two with an activity written behind it. A custom list
rejects a duplicate; the watchlist quietly ignores one.

*Report an issue…* opens a form (`screens/movie_details/report_issue.dart`) — a dropdown of the
usual catalog mistakes plus a description, required only for *Other*, where it is the only
thing telling an admin what to fix. The report is filed as `Open` through
`POST /MovieIssueReport`; `MovieIssueReportService` writes the reporter from the token, and
`GetDataSource` returns only a non-admin's own reports, so listing, editing and deleting all
stay inside what the caller filed. An owner can edit a report only while it is still open; an
admin closes it with a `PUT` carrying the status and a comment, which records who resolved it
and when.

Nothing reads the reports back yet — there is no list of filed reports on mobile and no admin
screen on the desktop — so for now they are only sent.

## Notes

- `MovieRequestService` publishes a `MovieRequested` message to RabbitMQ when a user requests a
  film. Nothing subscribes to it yet.
- All seed data lives in `HasData` in `Flix.Services/Database/FlixSeeder.cs`, so changing it
  requires a new migration.
- There is no backend test project.
