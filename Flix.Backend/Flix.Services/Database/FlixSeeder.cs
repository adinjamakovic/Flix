using System;
using System.Linq;
using Flix.Services.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace Flix.Services.Database
{
    public partial class FlixDbContext : DbContext
    {
        // Seeded password hashes are PBKDF2-SHA256, 100k iterations, 32 byte output,
        // matching UserService.HashPassword. The plaintext for each account is noted
        // inline next to its hash.
        protected void SeedData(ModelBuilder modelBuilder)
        {
            SeedCountries(modelBuilder);
            SeedLanguages(modelBuilder);
            SeedGenres(modelBuilder);
            SeedStudios(modelBuilder);
            SeedCastMembers(modelBuilder);
            SeedMovies(modelBuilder);
            SeedMovieGenres(modelBuilder);
            SeedMovieStudios(modelBuilder);
            SeedMovieCasts(modelBuilder);
            SeedUsers(modelBuilder);
            SeedUserFollows(modelBuilder);
            SeedUserBlocks(modelBuilder);
            SeedReviews(modelBuilder);
            SeedMovieLists(modelBuilder);
            SeedMovieListItems(modelBuilder);
            SeedClashes(modelBuilder);
            SeedClashEntries(modelBuilder);
            SeedClashVotes(modelBuilder);
            SeedActivities(modelBuilder);
            SeedMovieRequests(modelBuilder);
            SeedMovieIssueReports(modelBuilder);
            SeedUserReports(modelBuilder);
        }

        private static void SeedCountries(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Country>().HasData(
                new Country { Id = 1, Name = "United States", Code = "US" },
                new Country { Id = 2, Name = "United Kingdom", Code = "GB" },
                new Country { Id = 3, Name = "Japan", Code = "JP" },
                new Country { Id = 4, Name = "France", Code = "FR" },
                new Country { Id = 5, Name = "South Korea", Code = "KR" },
                new Country { Id = 6, Name = "Germany", Code = "DE" },
                new Country { Id = 7, Name = "Italy", Code = "IT" },
                new Country { Id = 8, Name = "Canada", Code = "CA" },
                new Country { Id = 9, Name = "Australia", Code = "AU" },
                new Country { Id = 10, Name = "Bosnia and Herzegovina", Code = "BA" },
                new Country { Id = 11, Name = "Malaysia", Code = "MY" },
                new Country { Id = 12, Name = "Vietnam", Code = "VN" },
                new Country { Id = 13, Name = "South Africa", Code = "ZA" });
        }

        private static void SeedLanguages(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Language>().HasData(
                new Language { Id = 1, Name = "English", Code = "en" },
                new Language { Id = 2, Name = "Japanese", Code = "ja" },
                new Language { Id = 3, Name = "French", Code = "fr" },
                new Language { Id = 4, Name = "Korean", Code = "ko" },
                new Language { Id = 5, Name = "German", Code = "de" },
                new Language { Id = 6, Name = "Italian", Code = "it" },
                new Language { Id = 7, Name = "Spanish", Code = "es" },
                new Language { Id = 8, Name = "Bosnian", Code = "bs" });
        }

        private static void SeedGenres(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Genre>().HasData(
                new Genre { Id = 1, Name = "Action" },
                new Genre { Id = 2, Name = "Adventure" },
                new Genre { Id = 3, Name = "Animation" },
                new Genre { Id = 4, Name = "Comedy" },
                new Genre { Id = 5, Name = "Crime" },
                new Genre { Id = 6, Name = "Drama" },
                new Genre { Id = 7, Name = "Fantasy" },
                new Genre { Id = 8, Name = "Horror" },
                new Genre { Id = 9, Name = "Mystery" },
                new Genre { Id = 10, Name = "Romance" },
                new Genre { Id = 11, Name = "Science Fiction" },
                new Genre { Id = 12, Name = "Thriller" });
        }

        private static void SeedStudios(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Studio>().HasData(
                new Studio
                {
                    Id = 1,
                    Name = "Paramount Pictures",
                    Description = "Hollywood studio founded in 1912 and the oldest still operating in the United States."
                },
                new Studio
                {
                    Id = 2,
                    Name = "Miramax",
                    Description = "American production and distribution company founded in 1979, known for independent cinema."
                },
                new Studio
                {
                    Id = 3,
                    Name = "Studio Ghibli",
                    Description = "Japanese animation studio founded in 1985 in Koganei, Tokyo by Hayao Miyazaki, Isao Takahata and Toshio Suzuki."
                },
                new Studio
                {
                    Id = 4,
                    Name = "Barunson E&A",
                    Description = "South Korean film production company based in Seoul, producer of Bong Joon-ho's Parasite."
                },
                new Studio
                {
                    Id = 5,
                    Name = "Warner Bros. Pictures",
                    Description = "American film studio founded in 1923, headquartered in Burbank, California."
                },
                new Studio
                {
                    Id = 6,
                    Name = "Universal Pictures",
                    Description = "American film studio founded in 1912, a division of NBCUniversal."
                },
                new Studio
                {
                    Id = 7,
                    Name = "A24",
                    Description = "American independent entertainment company founded in 2012 in New York City."
                },
                new Studio
                {
                    Id = 8,
                    Name = "Toho",
                    Description = "Japanese film studio founded in 1932, distributor of the Godzilla franchise and Studio Ghibli releases."
                },
                new Studio
                {
                    Id = 9,
                    Name = "Kennedy Miller Mitchell",
                    Description = "Australian production company founded in Sydney by George Miller and Byron Kennedy."
                },
                new Studio
                {
                    Id = 10,
                    Name = "Bavaria Film",
                    Description = "German film production company based in Grunwald near Munich, founded in 1919."
                });
        }

        private static void SeedCastMembers(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<CastMember>().HasData(
                new CastMember
                {
                    Id = 1,
                    FirstName = "Marlon",
                    LastName = "Brando",
                    CountryId = 1,
                    BirthDate = new DateTime(1924, 4, 3),
                    Biography = "American actor whose work with the Actors Studio reshaped screen performance, best known for A Streetcar Named Desire, On the Waterfront and The Godfather."
                },
                new CastMember
                {
                    Id = 2,
                    FirstName = "Al",
                    LastName = "Pacino",
                    CountryId = 1,
                    BirthDate = new DateTime(1940, 4, 25),
                    Biography = "American actor from East Harlem, New York, who rose to fame as Michael Corleone and went on to star in Serpico, Scarface and Heat."
                },
                new CastMember
                {
                    Id = 3,
                    FirstName = "Francis Ford",
                    LastName = "Coppola",
                    CountryId = 1,
                    BirthDate = new DateTime(1939, 4, 7),
                    Biography = "American director and screenwriter, a central figure of New Hollywood, who directed The Godfather trilogy and Apocalypse Now."
                },
                new CastMember
                {
                    Id = 4,
                    FirstName = "John",
                    LastName = "Travolta",
                    CountryId = 1,
                    BirthDate = new DateTime(1954, 2, 18),
                    Biography = "American actor and dancer who broke through with Saturday Night Fever and Grease before his career revival in Pulp Fiction."
                },
                new CastMember
                {
                    Id = 5,
                    FirstName = "Samuel L.",
                    LastName = "Jackson",
                    CountryId = 1,
                    BirthDate = new DateTime(1948, 12, 21),
                    Biography = "American actor raised in Chattanooga, Tennessee, and one of the highest-grossing performers in film history."
                },
                new CastMember
                {
                    Id = 6,
                    FirstName = "Quentin",
                    LastName = "Tarantino",
                    CountryId = 1,
                    BirthDate = new DateTime(1963, 3, 27),
                    Biography = "American director and screenwriter known for non-linear storytelling in Reservoir Dogs, Pulp Fiction and Kill Bill."
                },
                new CastMember
                {
                    Id = 7,
                    FirstName = "Hayao",
                    LastName = "Miyazaki",
                    CountryId = 3,
                    BirthDate = new DateTime(1941, 1, 5),
                    Biography = "Japanese animator and director, co-founder of Studio Ghibli and creator of My Neighbour Totoro, Princess Mononoke and Spirited Away."
                },
                new CastMember
                {
                    Id = 8,
                    FirstName = "Rumi",
                    LastName = "Hiiragi",
                    CountryId = 3,
                    BirthDate = new DateTime(1987, 8, 1),
                    Biography = "Japanese actress who voiced Chihiro in Spirited Away at the age of thirteen."
                },
                new CastMember
                {
                    Id = 9,
                    FirstName = "Bong",
                    LastName = "Joon-ho",
                    CountryId = 5,
                    BirthDate = new DateTime(1969, 9, 14),
                    Biography = "South Korean director and screenwriter whose films Memories of Murder, The Host and Parasite blend genre with social critique."
                },
                new CastMember
                {
                    Id = 10,
                    FirstName = "Song",
                    LastName = "Kang-ho",
                    CountryId = 5,
                    BirthDate = new DateTime(1967, 1, 17),
                    Biography = "South Korean actor and frequent Bong Joon-ho collaborator, winner of Best Actor at Cannes for Broker."
                },
                new CastMember
                {
                    Id = 11,
                    FirstName = "Christopher",
                    LastName = "Nolan",
                    CountryId = 2,
                    BirthDate = new DateTime(1970, 7, 30),
                    Biography = "British-American director known for Memento, The Dark Knight trilogy, Inception, Interstellar and Oppenheimer."
                },
                new CastMember
                {
                    Id = 12,
                    FirstName = "Leonardo",
                    LastName = "DiCaprio",
                    CountryId = 1,
                    BirthDate = new DateTime(1974, 11, 11),
                    Biography = "American actor and environmental activist known for Titanic, The Departed, Inception and The Revenant."
                },
                new CastMember
                {
                    Id = 13,
                    FirstName = "Christian",
                    LastName = "Bale",
                    CountryId = 2,
                    BirthDate = new DateTime(1974, 1, 30),
                    Biography = "Welsh actor known for extreme physical transformations in American Psycho, The Machinist and The Dark Knight trilogy."
                },
                new CastMember
                {
                    Id = 14,
                    FirstName = "Heath",
                    LastName = "Ledger",
                    CountryId = 9,
                    BirthDate = new DateTime(1979, 4, 4),
                    Biography = "Australian actor from Perth whose performance as the Joker in The Dark Knight earned a posthumous Academy Award."
                },
                new CastMember
                {
                    Id = 15,
                    FirstName = "Jean-Pierre",
                    LastName = "Jeunet",
                    CountryId = 4,
                    BirthDate = new DateTime(1953, 9, 3),
                    Biography = "French director known for the distinctive visual style of Delicatessen, The City of Lost Children and Amelie."
                },
                new CastMember
                {
                    Id = 16,
                    FirstName = "Audrey",
                    LastName = "Tautou",
                    CountryId = 4,
                    BirthDate = new DateTime(1976, 8, 9),
                    Biography = "French actress who became internationally known as the title character in Amelie and later starred in A Very Long Engagement."
                },
                new CastMember
                {
                    Id = 17,
                    FirstName = "Giuseppe",
                    LastName = "Tornatore",
                    CountryId = 7,
                    BirthDate = new DateTime(1956, 5, 27),
                    Biography = "Italian director from Bagheria, Sicily, whose Cinema Paradiso won the Academy Award for Best Foreign Language Film."
                },
                new CastMember
                {
                    Id = 18,
                    FirstName = "Philippe",
                    LastName = "Noiret",
                    CountryId = 4,
                    BirthDate = new DateTime(1930, 10, 1),
                    Biography = "French actor of stage and screen who appeared in more than a hundred films, including Cinema Paradiso and Il Postino."
                },
                new CastMember
                {
                    Id = 19,
                    FirstName = "Michelle",
                    LastName = "Yeoh",
                    CountryId = 11,
                    BirthDate = new DateTime(1962, 8, 6),
                    Biography = "Malaysian actress known for Hong Kong action cinema, Crouching Tiger, Hidden Dragon and her Academy Award-winning role in Everything Everywhere All at Once."
                },
                new CastMember
                {
                    Id = 20,
                    FirstName = "Ke Huy",
                    LastName = "Quan",
                    CountryId = 12,
                    BirthDate = new DateTime(1971, 8, 20),
                    Biography = "Vietnamese-born American actor who starred as a child in Indiana Jones and the Temple of Doom and The Goonies before his return in Everything Everywhere All at Once."
                },
                new CastMember
                {
                    Id = 21,
                    FirstName = "Daniel",
                    LastName = "Kwan",
                    CountryId = 1,
                    BirthDate = new DateTime(1988, 2, 10),
                    Biography = "American director and one half of the duo Daniels, co-director of Swiss Army Man and Everything Everywhere All at Once."
                },
                new CastMember
                {
                    Id = 22,
                    FirstName = "George",
                    LastName = "Miller",
                    CountryId = 9,
                    BirthDate = new DateTime(1945, 3, 3),
                    Biography = "Australian director and former medical doctor who created the Mad Max series and directed Babe and Happy Feet."
                },
                new CastMember
                {
                    Id = 23,
                    FirstName = "Charlize",
                    LastName = "Theron",
                    CountryId = 13,
                    BirthDate = new DateTime(1975, 8, 7),
                    Biography = "South African-American actress and producer who won an Academy Award for Monster and starred as Furiosa in Mad Max: Fury Road."
                },
                new CastMember
                {
                    Id = 24,
                    FirstName = "Tom",
                    LastName = "Hardy",
                    CountryId = 2,
                    BirthDate = new DateTime(1977, 9, 15),
                    Biography = "English actor known for Bronson, Inception, Mad Max: Fury Road and the Venom films."
                },
                new CastMember
                {
                    Id = 25,
                    FirstName = "Wolfgang",
                    LastName = "Petersen",
                    CountryId = 6,
                    BirthDate = new DateTime(1941, 3, 14),
                    Biography = "German director who broke through with Das Boot and went on to make The NeverEnding Story, Air Force One and Troy."
                },
                new CastMember
                {
                    Id = 26,
                    FirstName = "Jurgen",
                    LastName = "Prochnow",
                    CountryId = 6,
                    BirthDate = new DateTime(1941, 6, 10),
                    Biography = "German actor best known internationally as the U-boat captain in Das Boot."
                },
                new CastMember
                {
                    Id = 27,
                    FirstName = "Akira",
                    LastName = "Kurosawa",
                    CountryId = 3,
                    BirthDate = new DateTime(1910, 3, 23),
                    Biography = "Japanese director whose Rashomon, Seven Samurai and Ran made him one of the most influential filmmakers in cinema history."
                },
                new CastMember
                {
                    Id = 28,
                    FirstName = "Toshiro",
                    LastName = "Mifune",
                    CountryId = 3,
                    BirthDate = new DateTime(1920, 4, 1),
                    Biography = "Japanese actor who appeared in sixteen films with Akira Kurosawa, among them Seven Samurai, Yojimbo and Throne of Blood."
                });
        }

        private static void SeedMovies(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Movie>().HasData(
                new Movie
                {
                    Id = 1,
                    Title = "The Godfather",
                    Description = "The ageing patriarch of an organised crime dynasty transfers control of his clandestine empire to his reluctant youngest son.",
                    TrailerUrl = "https://www.youtube.com/watch?v=sY1S34973zA",
                    ReleaseDate = new DateTime(1972, 3, 24),
                    DurationMinutes = 175,
                    Views = 184_320,
                    IsEnabled = true,
                    CountryId = 1,
                    LanguageId = 1
                },
                new Movie
                {
                    Id = 2,
                    Title = "Pulp Fiction",
                    Description = "The lives of two mob hitmen, a boxer, a gangster's wife and a pair of diner bandits intertwine in four tales of violence and redemption.",
                    TrailerUrl = "https://www.youtube.com/watch?v=s7EdQ4FqbhY",
                    ReleaseDate = new DateTime(1994, 10, 14),
                    DurationMinutes = 154,
                    Views = 167_845,
                    IsEnabled = true,
                    CountryId = 1,
                    LanguageId = 1
                },
                new Movie
                {
                    Id = 3,
                    Title = "Spirited Away",
                    Description = "During her family's move to the suburbs, a sullen ten-year-old girl wanders into a world ruled by gods, witches and spirits where humans are changed into beasts.",
                    TrailerUrl = "https://www.youtube.com/watch?v=ByXuk9QqQkk",
                    ReleaseDate = new DateTime(2001, 7, 20),
                    DurationMinutes = 125,
                    Views = 142_190,
                    IsEnabled = true,
                    CountryId = 3,
                    LanguageId = 2
                },
                new Movie
                {
                    Id = 4,
                    Title = "Parasite",
                    Description = "Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the destitute Kim clan.",
                    TrailerUrl = "https://www.youtube.com/watch?v=5xH0HfJHsaY",
                    ReleaseDate = new DateTime(2019, 5, 30),
                    DurationMinutes = 132,
                    Views = 158_073,
                    IsEnabled = true,
                    CountryId = 5,
                    LanguageId = 4
                },
                new Movie
                {
                    Id = 5,
                    Title = "Inception",
                    Description = "A thief who steals corporate secrets through dream-sharing technology is given the inverse task of planting an idea into the mind of a chief executive.",
                    TrailerUrl = "https://www.youtube.com/watch?v=YoHD9XEInc0",
                    ReleaseDate = new DateTime(2010, 7, 16),
                    DurationMinutes = 148,
                    Views = 203_557,
                    IsEnabled = true,
                    CountryId = 1,
                    LanguageId = 1
                },
                new Movie
                {
                    Id = 6,
                    Title = "The Dark Knight",
                    Description = "Batman raises the stakes in his war on crime until a rising criminal mastermind known as the Joker forces Gotham into anarchy.",
                    TrailerUrl = "https://www.youtube.com/watch?v=EXeTwQWrcwY",
                    ReleaseDate = new DateTime(2008, 7, 18),
                    DurationMinutes = 152,
                    Views = 221_408,
                    IsEnabled = true,
                    CountryId = 1,
                    LanguageId = 1
                },
                new Movie
                {
                    Id = 7,
                    Title = "Amelie",
                    Description = "A shy waitress in Montmartre decides to change the lives of those around her for the better while struggling with her own isolation.",
                    TrailerUrl = "https://www.youtube.com/watch?v=HUECWi5pX7o",
                    ReleaseDate = new DateTime(2001, 4, 25),
                    DurationMinutes = 122,
                    Views = 96_412,
                    IsEnabled = true,
                    CountryId = 4,
                    LanguageId = 3
                },
                new Movie
                {
                    Id = 8,
                    Title = "Cinema Paradiso",
                    Description = "A filmmaker recalls his childhood in a Sicilian village and the friendship with the projectionist who taught him to love the movies.",
                    TrailerUrl = "https://www.youtube.com/watch?v=Ah0kPnzzrs4",
                    ReleaseDate = new DateTime(1988, 11, 17),
                    DurationMinutes = 155,
                    Views = 74_265,
                    IsEnabled = true,
                    CountryId = 7,
                    LanguageId = 6
                },
                new Movie
                {
                    Id = 9,
                    Title = "Everything Everywhere All at Once",
                    Description = "An overwhelmed laundromat owner facing an audit discovers she must connect with parallel versions of herself to stop a threat spanning the multiverse.",
                    TrailerUrl = "https://www.youtube.com/watch?v=wxN1T1uxQ2g",
                    ReleaseDate = new DateTime(2022, 3, 25),
                    DurationMinutes = 139,
                    Views = 131_776,
                    IsEnabled = true,
                    CountryId = 1,
                    LanguageId = 1
                },
                new Movie
                {
                    Id = 10,
                    Title = "Mad Max: Fury Road",
                    Description = "In a post-apocalyptic wasteland, a drifter and a rebel warrior flee from a tyrant and his war parties in a relentless convoy chase.",
                    TrailerUrl = "https://www.youtube.com/watch?v=hEJnMQG9ev8",
                    ReleaseDate = new DateTime(2015, 5, 15),
                    DurationMinutes = 120,
                    Views = 148_903,
                    IsEnabled = true,
                    CountryId = 9,
                    LanguageId = 1
                },
                new Movie
                {
                    Id = 11,
                    Title = "Das Boot",
                    Description = "The claustrophobic patrol of a German U-boat crew in the Atlantic during the Second World War, told from inside the submarine.",
                    TrailerUrl = "https://www.youtube.com/watch?v=zTaS7OFHM6M",
                    ReleaseDate = new DateTime(1981, 9, 17),
                    DurationMinutes = 149,
                    Views = 52_338,
                    IsEnabled = true,
                    CountryId = 6,
                    LanguageId = 5
                },
                new Movie
                {
                    Id = 12,
                    Title = "Seven Samurai",
                    Description = "A poor village under attack by bandits recruits seven masterless samurai to help them defend themselves.",
                    TrailerUrl = "https://www.youtube.com/watch?v=wErvXaYtDGE",
                    ReleaseDate = new DateTime(1954, 4, 26),
                    DurationMinutes = 207,
                    Views = 68_150,
                    IsEnabled = true,
                    CountryId = 3,
                    LanguageId = 2
                });
        }

        private static void SeedMovieGenres(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<MovieGenre>().HasData(
                new MovieGenre { Id = 1, MovieId = 1, GenreId = 5 },
                new MovieGenre { Id = 2, MovieId = 1, GenreId = 6 },
                new MovieGenre { Id = 3, MovieId = 2, GenreId = 5 },
                new MovieGenre { Id = 4, MovieId = 2, GenreId = 6 },
                new MovieGenre { Id = 5, MovieId = 2, GenreId = 12 },
                new MovieGenre { Id = 6, MovieId = 3, GenreId = 3 },
                new MovieGenre { Id = 7, MovieId = 3, GenreId = 2 },
                new MovieGenre { Id = 8, MovieId = 3, GenreId = 7 },
                new MovieGenre { Id = 9, MovieId = 4, GenreId = 6 },
                new MovieGenre { Id = 10, MovieId = 4, GenreId = 12 },
                new MovieGenre { Id = 11, MovieId = 4, GenreId = 4 },
                new MovieGenre { Id = 12, MovieId = 5, GenreId = 1 },
                new MovieGenre { Id = 13, MovieId = 5, GenreId = 11 },
                new MovieGenre { Id = 14, MovieId = 5, GenreId = 12 },
                new MovieGenre { Id = 15, MovieId = 6, GenreId = 1 },
                new MovieGenre { Id = 16, MovieId = 6, GenreId = 5 },
                new MovieGenre { Id = 17, MovieId = 6, GenreId = 6 },
                new MovieGenre { Id = 18, MovieId = 7, GenreId = 4 },
                new MovieGenre { Id = 19, MovieId = 7, GenreId = 10 },
                new MovieGenre { Id = 20, MovieId = 8, GenreId = 6 },
                new MovieGenre { Id = 21, MovieId = 8, GenreId = 10 },
                new MovieGenre { Id = 22, MovieId = 9, GenreId = 1 },
                new MovieGenre { Id = 23, MovieId = 9, GenreId = 2 },
                new MovieGenre { Id = 24, MovieId = 9, GenreId = 11 },
                new MovieGenre { Id = 25, MovieId = 10, GenreId = 1 },
                new MovieGenre { Id = 26, MovieId = 10, GenreId = 2 },
                new MovieGenre { Id = 27, MovieId = 10, GenreId = 11 },
                new MovieGenre { Id = 28, MovieId = 11, GenreId = 6 },
                new MovieGenre { Id = 29, MovieId = 11, GenreId = 12 },
                new MovieGenre { Id = 30, MovieId = 12, GenreId = 1 },
                new MovieGenre { Id = 31, MovieId = 12, GenreId = 2 },
                new MovieGenre { Id = 32, MovieId = 12, GenreId = 6 });
        }

        private static void SeedMovieStudios(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<MovieStudio>().HasData(
                new MovieStudio { Id = 1, MovieId = 1, StudioId = 1 },
                new MovieStudio { Id = 2, MovieId = 2, StudioId = 2 },
                new MovieStudio { Id = 3, MovieId = 3, StudioId = 3 },
                new MovieStudio { Id = 4, MovieId = 3, StudioId = 8 },
                new MovieStudio { Id = 5, MovieId = 4, StudioId = 4 },
                new MovieStudio { Id = 6, MovieId = 5, StudioId = 5 },
                new MovieStudio { Id = 7, MovieId = 6, StudioId = 5 },
                new MovieStudio { Id = 8, MovieId = 7, StudioId = 2 },
                new MovieStudio { Id = 9, MovieId = 8, StudioId = 2 },
                new MovieStudio { Id = 10, MovieId = 9, StudioId = 7 },
                new MovieStudio { Id = 11, MovieId = 10, StudioId = 5 },
                new MovieStudio { Id = 12, MovieId = 10, StudioId = 9 },
                new MovieStudio { Id = 13, MovieId = 11, StudioId = 10 },
                new MovieStudio { Id = 14, MovieId = 12, StudioId = 8 });
        }

        private static void SeedMovieCasts(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<MovieCast>().HasData(
                // The Godfather
                new MovieCast { Id = 1, MovieId = 1, CastMemberId = 3, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 2, MovieId = 1, CastMemberId = 1, Role = CastRole.Actor, CharacterName = "Don Vito Corleone", OrderOfAppearence = 1 },
                new MovieCast { Id = 3, MovieId = 1, CastMemberId = 2, Role = CastRole.Actor, CharacterName = "Michael Corleone", OrderOfAppearence = 2 },
                // Pulp Fiction
                new MovieCast { Id = 4, MovieId = 2, CastMemberId = 6, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 5, MovieId = 2, CastMemberId = 4, Role = CastRole.Actor, CharacterName = "Vincent Vega", OrderOfAppearence = 1 },
                new MovieCast { Id = 6, MovieId = 2, CastMemberId = 5, Role = CastRole.Actor, CharacterName = "Jules Winnfield", OrderOfAppearence = 2 },
                // Spirited Away
                new MovieCast { Id = 7, MovieId = 3, CastMemberId = 7, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 8, MovieId = 3, CastMemberId = 8, Role = CastRole.Actor, CharacterName = "Chihiro Ogino", OrderOfAppearence = 1 },
                // Parasite
                new MovieCast { Id = 9, MovieId = 4, CastMemberId = 9, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 10, MovieId = 4, CastMemberId = 10, Role = CastRole.Actor, CharacterName = "Kim Ki-taek", OrderOfAppearence = 1 },
                // Inception
                new MovieCast { Id = 11, MovieId = 5, CastMemberId = 11, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 12, MovieId = 5, CastMemberId = 12, Role = CastRole.Actor, CharacterName = "Dom Cobb", OrderOfAppearence = 1 },
                new MovieCast { Id = 13, MovieId = 5, CastMemberId = 24, Role = CastRole.Actor, CharacterName = "Eames", OrderOfAppearence = 2 },
                // The Dark Knight
                new MovieCast { Id = 14, MovieId = 6, CastMemberId = 11, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 15, MovieId = 6, CastMemberId = 13, Role = CastRole.Actor, CharacterName = "Bruce Wayne / Batman", OrderOfAppearence = 1 },
                new MovieCast { Id = 16, MovieId = 6, CastMemberId = 14, Role = CastRole.Actor, CharacterName = "The Joker", OrderOfAppearence = 2 },
                // Amelie
                new MovieCast { Id = 17, MovieId = 7, CastMemberId = 15, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 18, MovieId = 7, CastMemberId = 16, Role = CastRole.Actor, CharacterName = "Amelie Poulain", OrderOfAppearence = 1 },
                // Cinema Paradiso
                new MovieCast { Id = 19, MovieId = 8, CastMemberId = 17, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 20, MovieId = 8, CastMemberId = 18, Role = CastRole.Actor, CharacterName = "Alfredo", OrderOfAppearence = 1 },
                // Everything Everywhere All at Once
                new MovieCast { Id = 21, MovieId = 9, CastMemberId = 21, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 22, MovieId = 9, CastMemberId = 19, Role = CastRole.Actor, CharacterName = "Evelyn Quan Wang", OrderOfAppearence = 1 },
                new MovieCast { Id = 23, MovieId = 9, CastMemberId = 20, Role = CastRole.Actor, CharacterName = "Waymond Wang", OrderOfAppearence = 2 },
                // Mad Max: Fury Road
                new MovieCast { Id = 24, MovieId = 10, CastMemberId = 22, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 25, MovieId = 10, CastMemberId = 24, Role = CastRole.Actor, CharacterName = "Max Rockatansky", OrderOfAppearence = 1 },
                new MovieCast { Id = 26, MovieId = 10, CastMemberId = 23, Role = CastRole.Actor, CharacterName = "Imperator Furiosa", OrderOfAppearence = 2 },
                // Das Boot
                new MovieCast { Id = 27, MovieId = 11, CastMemberId = 25, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 28, MovieId = 11, CastMemberId = 26, Role = CastRole.Actor, CharacterName = "Der Kaleun", OrderOfAppearence = 1 },
                // Seven Samurai
                new MovieCast { Id = 29, MovieId = 12, CastMemberId = 27, Role = CastRole.Director, OrderOfAppearence = 0 },
                new MovieCast { Id = 30, MovieId = 12, CastMemberId = 28, Role = CastRole.Actor, CharacterName = "Kikuchiyo", OrderOfAppearence = 1 });
        }

        private static void SeedUsers(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = 1,
                    FirstName = "Adin",
                    LastName = "Jamakovic",
                    Email = "adin.jamakovic@flix.app",
                    Username = "adin.jamakovic",
                    PasswordSalt = "c2FsdF91c2VyXzAxMjM0NQ==",
                    PasswordHash = "rHD2Yh73AE02oeak4nQOAzToFyW1gjxDH1Z4lfv+ChI=", // password: Admin123!
                    IsAdmin = true,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 15, 9, 0, 0),
                    LastLoginAt = new DateTime(2026, 7, 16, 8, 42, 0),
                    PhoneNumber = "+387 61 234 567",
                    Bio = "Platform maintainer. Somewhere between a Kurosawa retrospective and the next release.",
                    CountryId = 10
                },
                new User
                {
                    Id = 2,
                    FirstName = "Emma",
                    LastName = "Clarke",
                    Email = "emma.clarke@gmail.com",
                    Username = "emmaclarke",
                    PasswordSalt = "c2FsdF91c2VyXzAyMzQ1Ng==",
                    PasswordHash = "0NKgFZKMHKecbrVPU9chw7ICV923UYEBgrszYQB/Auk=", // password: Test123!
                    IsAdmin = false,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 3, 2, 14, 25, 0),
                    LastLoginAt = new DateTime(2026, 7, 15, 20, 11, 0),
                    PhoneNumber = "+44 7700 900412",
                    Bio = "Film studies graduate in Manchester. Partial to slow cinema and anything shot on 35mm.",
                    CountryId = 2
                },
                new User
                {
                    Id = 3,
                    FirstName = "Liam",
                    LastName = "Novak",
                    Email = "liam.novak@outlook.com",
                    Username = "liamnovak",
                    PasswordSalt = "c2FsdF91c2VyXzAzNDU2Nw==",
                    PasswordHash = "HG93pIZwDVehedrtudgmNqn5FXRmL6DTZl/Vbzh8V7Y=", // password: Test123!
                    IsAdmin = false,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 4, 18, 11, 5, 0),
                    LastLoginAt = new DateTime(2026, 7, 14, 19, 30, 0),
                    PhoneNumber = "+1 416 555 0148",
                    Bio = "Toronto-based editor. I keep a diary of every rewatch, which is probably too many.",
                    CountryId = 8
                },
                new User
                {
                    Id = 4,
                    FirstName = "Sofia",
                    LastName = "Rossi",
                    Email = "sofia.rossi@libero.it",
                    Username = "sofiarossi",
                    PasswordSalt = "c2FsdF91c2VyXzA0NTY3OA==",
                    PasswordHash = "QMoCRAuTRA4kgSH7W2ifOLkdcsFuLYavdLC0z/TO3KU=", // password: Test123!
                    IsAdmin = false,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 6, 9, 17, 48, 0),
                    LastLoginAt = new DateTime(2026, 7, 17, 10, 3, 0),
                    PhoneNumber = "+39 320 555 0119",
                    Bio = "From Bologna. Italian neorealism first, everything else after.",
                    CountryId = 7
                },
                new User
                {
                    Id = 5,
                    FirstName = "Kenji",
                    LastName = "Tanaka",
                    Email = "kenji.tanaka@yahoo.co.jp",
                    Username = "kenjitanaka",
                    PasswordSalt = "c2FsdF91c2VyXzA1Njc4OQ==",
                    PasswordHash = "l70pUC0q+1w9rcqVXxAk6ZQs1N6IaZAWw3KK5OLx+bE=", // password: Test123!
                    IsAdmin = false,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 8, 21, 6, 15, 0),
                    LastLoginAt = new DateTime(2026, 7, 17, 22, 55, 0),
                    PhoneNumber = "+81 90 1234 5678",
                    Bio = "Osaka. Ghibli completionist, Kurosawa apologist, occasional subtitler.",
                    CountryId = 3
                },
                new User
                {
                    Id = 6,
                    FirstName = "Marcus",
                    LastName = "Webb",
                    Email = "marcus.webb@protonmail.com",
                    Username = "marcuswebb",
                    PasswordSalt = "c2FsdF91c2VyXzA2Nzg5MA==",
                    PasswordHash = "OavnspkOZwNRsdv1VTWmMq83+HJJeZ6z43huQXc8bnY=", // password: Test123!
                    IsAdmin = false,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 10, 4, 13, 40, 0),
                    LastLoginAt = new DateTime(2026, 7, 12, 16, 20, 0),
                    PhoneNumber = "+1 512 555 0173",
                    Bio = "Austin, Texas. Blockbusters on the biggest screen I can find.",
                    CountryId = 1
                },
                new User
                {
                    Id = 7,
                    FirstName = "Chloe",
                    LastName = "Dubois",
                    Email = "chloe.dubois@orange.fr",
                    Username = "chloedubois",
                    PasswordSalt = "c2FsdF91c2VyXzA3ODkwMQ==",
                    PasswordHash = "7NSJsmuMeW7SwJXhQS3Lgmvj9srSZWke+pS1LSDzc84=", // password: Test123!
                    IsAdmin = false,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 12, 8, 55, 0),
                    LastLoginAt = new DateTime(2026, 7, 16, 12, 47, 0),
                    PhoneNumber = "+33 6 12 34 56 78",
                    Bio = "Lyon. I make lists far more often than I finish them.",
                    CountryId = 4
                },
                new User
                {
                    Id = 8,
                    FirstName = "Daniel",
                    LastName = "Kim",
                    Email = "daniel.kim@naver.com",
                    Username = "danielkim",
                    PasswordSalt = "c2FsdF91c2VyXzA4OTAxMg==",
                    PasswordHash = "ibSjrpZ3IdWS5fZWW9sQcGffMXvrCQTWSqr1NT5vUFc=", // password: Test123!
                    IsAdmin = false,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 2, 27, 21, 10, 0),
                    LastLoginAt = new DateTime(2026, 7, 17, 7, 5, 0),
                    PhoneNumber = "+82 10 9876 5432",
                    Bio = "Seoul. Genre cinema, thrillers, and arguing about endings.",
                    CountryId = 5
                },
                new User
                {
                    Id = 9,
                    FirstName = "Amelia",
                    LastName = "Hughes",
                    Email = "amelia.hughes@gmail.com",
                    Username = "ameliahughes",
                    PasswordSalt = "c2FsdF91c2VyXzA5MDEyMw==",
                    PasswordHash = "M0+tSbxsqqz4MCSJ6BSAsS26awb3Z15PGfbr1UGCZOw=", // password: Test123!
                    IsAdmin = false,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 5, 6, 15, 30, 0),
                    LastLoginAt = new DateTime(2026, 7, 11, 18, 22, 0),
                    PhoneNumber = "+61 4 1234 5678",
                    Bio = "Melbourne. Australian cinema, practical effects, and a soft spot for road movies.",
                    CountryId = 9
                },
                new User
                {
                    Id = 10,
                    FirstName = "Noah",
                    LastName = "Fischer",
                    Email = "noah.fischer@web.de",
                    Username = "noahfischer",
                    PasswordSalt = "c2FsdF91c2VyXzEwMTIzNA==",
                    PasswordHash = "B5YC1xf276jA12l+Nv+cGjo52IrXkCBl58sz/rIKOBo=", // password: Test123!
                    IsAdmin = false,
                    IsActive = false,
                    CreatedAt = new DateTime(2025, 9, 19, 10, 12, 0),
                    LastLoginAt = new DateTime(2026, 3, 28, 9, 41, 0),
                    PhoneNumber = "+49 151 23456789",
                    Bio = "Hamburg. Account on hold while I finish my thesis on post-war German film.",
                    CountryId = 6
                });
        }

        private static void SeedUserFollows(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<UserFollow>().HasData(
                new UserFollow { Id = 1, FollowerId = 2, FollowingId = 3, IsFriend = true, CreatedAt = new DateTime(2024, 5, 2, 12, 0, 0) },
                new UserFollow { Id = 2, FollowerId = 3, FollowingId = 2, IsFriend = true, CreatedAt = new DateTime(2024, 5, 2, 18, 30, 0) },
                new UserFollow { Id = 3, FollowerId = 2, FollowingId = 5, IsFriend = false, CreatedAt = new DateTime(2024, 9, 14, 9, 15, 0) },
                new UserFollow { Id = 4, FollowerId = 4, FollowingId = 5, IsFriend = false, CreatedAt = new DateTime(2024, 9, 20, 20, 45, 0) },
                new UserFollow { Id = 5, FollowerId = 5, FollowingId = 4, IsFriend = true, CreatedAt = new DateTime(2024, 9, 21, 7, 10, 0) },
                new UserFollow { Id = 6, FollowerId = 4, FollowingId = 7, IsFriend = true, CreatedAt = new DateTime(2025, 2, 3, 16, 5, 0) },
                new UserFollow { Id = 7, FollowerId = 7, FollowingId = 4, IsFriend = true, CreatedAt = new DateTime(2025, 2, 3, 16, 40, 0) },
                new UserFollow { Id = 8, FollowerId = 6, FollowingId = 9, IsFriend = false, CreatedAt = new DateTime(2025, 6, 11, 11, 25, 0) },
                new UserFollow { Id = 9, FollowerId = 8, FollowingId = 5, IsFriend = false, CreatedAt = new DateTime(2025, 7, 8, 13, 55, 0) },
                new UserFollow { Id = 10, FollowerId = 9, FollowingId = 6, IsFriend = false, CreatedAt = new DateTime(2025, 8, 1, 19, 0, 0) },
                new UserFollow { Id = 11, FollowerId = 3, FollowingId = 8, IsFriend = false, CreatedAt = new DateTime(2025, 11, 22, 10, 30, 0) },
                new UserFollow { Id = 12, FollowerId = 7, FollowingId = 2, IsFriend = false, CreatedAt = new DateTime(2026, 1, 9, 21, 15, 0) });
        }

        private static void SeedUserBlocks(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<UserBlock>().HasData(
                new UserBlock { Id = 1, BlockerId = 2, BlockedId = 10, CreatedAt = new DateTime(2026, 2, 14, 9, 20, 0) },
                new UserBlock { Id = 2, BlockerId = 5, BlockedId = 6, CreatedAt = new DateTime(2026, 3, 30, 17, 45, 0) },
                new UserBlock { Id = 3, BlockerId = 9, BlockedId = 10, CreatedAt = new DateTime(2026, 4, 22, 8, 5, 0) });
        }

        private static void SeedReviews(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Review>().HasData(
                new Review
                {
                    Id = 1,
                    UserId = 2,
                    MovieId = 1,
                    Rating = 5.0m,
                    IsLiked = true,
                    Content = "The pacing is unhurried in a way films rarely risk now. Every scene at the Corleone table does double duty as family drama and power broking, and Brando plays authority as exhaustion rather than menace.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = false,
                    IsRewatch = true,
                    CreatedAt = new DateTime(2025, 11, 3, 21, 40, 0)
                },
                new Review
                {
                    Id = 2,
                    UserId = 3,
                    MovieId = 2,
                    Rating = 4.5m,
                    IsLiked = true,
                    Content = "Third rewatch and the structure still holds. The diner bookends work because the middle chapters earn them, not because the trick is clever.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = true,
                    IsRewatch = true,
                    CreatedAt = new DateTime(2025, 12, 18, 23, 5, 0)
                },
                new Review
                {
                    Id = 3,
                    UserId = 5,
                    MovieId = 3,
                    Rating = 5.0m,
                    IsLiked = true,
                    Content = "Watched it again with my daughter. The bathhouse sequence has more invention in ten minutes than most films manage in two hours, and none of it is explained to you.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = true,
                    IsRewatch = true,
                    CreatedAt = new DateTime(2026, 1, 7, 19, 25, 0),
                    UpdatedAt = new DateTime(2026, 1, 8, 8, 10, 0)
                },
                new Review
                {
                    Id = 4,
                    UserId = 8,
                    MovieId = 4,
                    Rating = 5.0m,
                    IsLiked = true,
                    Content = "The tonal turn halfway through is the whole point, and it lands because the first hour is played as comedy without condescension. The basement reveal reframes every earlier scene.",
                    ContainsSpoilers = true,
                    IsDiaryEntry = false,
                    IsRewatch = false,
                    CreatedAt = new DateTime(2026, 2, 2, 14, 50, 0)
                },
                new Review
                {
                    Id = 5,
                    UserId = 6,
                    MovieId = 5,
                    Rating = 4.0m,
                    IsLiked = true,
                    Content = "Structurally ambitious and beautifully staged, though the emotional core never quite matches the ingenuity of the mechanics. The hallway fight is still unmatched.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = false,
                    IsRewatch = false,
                    CreatedAt = new DateTime(2026, 2, 20, 20, 15, 0)
                },
                new Review
                {
                    Id = 6,
                    UserId = 6,
                    MovieId = 6,
                    Rating = 4.5m,
                    IsLiked = true,
                    Content = "Ledger reorganises the film around himself every time he appears. The ferry sequence is the closest a blockbuster has come to an honest moral argument.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = false,
                    IsRewatch = true,
                    CreatedAt = new DateTime(2026, 3, 5, 22, 30, 0)
                },
                new Review
                {
                    Id = 7,
                    UserId = 7,
                    MovieId = 7,
                    Rating = 4.5m,
                    IsLiked = true,
                    Content = "Saw it again at a repertory screening in Lyon. The saturated palette should be exhausting and somehow never is. Tautou carries the whole thing on small gestures.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = true,
                    IsRewatch = true,
                    CreatedAt = new DateTime(2026, 3, 21, 18, 0, 0)
                },
                new Review
                {
                    Id = 8,
                    UserId = 4,
                    MovieId = 8,
                    Rating = 5.0m,
                    IsLiked = true,
                    Content = "My grandfather ran a projector in a village not unlike this one. The final reel is sentimental and I do not care in the slightest.",
                    ContainsSpoilers = true,
                    IsDiaryEntry = false,
                    IsRewatch = false,
                    CreatedAt = new DateTime(2026, 4, 9, 21, 10, 0)
                },
                new Review
                {
                    Id = 9,
                    UserId = 3,
                    MovieId = 9,
                    Rating = 4.0m,
                    IsLiked = true,
                    Content = "Maximalist to a fault, but the editing is doing genuinely new things and the mother-daughter thread survives the chaos intact. Yeoh is extraordinary.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = false,
                    IsRewatch = false,
                    CreatedAt = new DateTime(2026, 5, 2, 16, 35, 0)
                },
                new Review
                {
                    Id = 10,
                    UserId = 9,
                    MovieId = 10,
                    Rating = 4.5m,
                    IsLiked = true,
                    Content = "Practical stunts, real dust, minimal dialogue. Miller cuts on movement so consistently that the geography of the chase is never once confusing.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = true,
                    IsRewatch = false,
                    CreatedAt = new DateTime(2026, 5, 24, 20, 5, 0)
                },
                new Review
                {
                    Id = 11,
                    UserId = 10,
                    MovieId = 11,
                    Rating = 4.5m,
                    IsLiked = true,
                    Content = "The sound design does most of the work. Long stretches of nothing but hull noise and breathing, and it is more tense than any action sequence.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = false,
                    IsRewatch = false,
                    CreatedAt = new DateTime(2026, 1, 30, 22, 45, 0)
                },
                new Review
                {
                    Id = 12,
                    UserId = 5,
                    MovieId = 12,
                    Rating = 5.0m,
                    IsLiked = true,
                    Content = "Every action film since has borrowed from the final battle in the rain. What holds up better is the first hour of recruitment, which is patient character work and nothing else.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = false,
                    IsRewatch = true,
                    CreatedAt = new DateTime(2026, 6, 14, 17, 20, 0),
                    UpdatedAt = new DateTime(2026, 6, 15, 9, 0, 0)
                },
                new Review
                {
                    Id = 13,
                    UserId = 2,
                    MovieId = 4,
                    Rating = 4.0m,
                    IsLiked = true,
                    Content = "Impeccably controlled, though I found the final act tips into a register the rest of the film had been careful to avoid.",
                    ContainsSpoilers = false,
                    IsDiaryEntry = false,
                    IsRewatch = false,
                    CreatedAt = new DateTime(2026, 6, 28, 19, 55, 0)
                },
                new Review
                {
                    Id = 14,
                    UserId = 8,
                    MovieId = 6,
                    Rating = 3.5m,
                    IsLiked = false,
                    Content = "Excellent villain, overlong third act. The Two-Face material would have been a better film on its own than a coda to this one.",
                    ContainsSpoilers = true,
                    IsDiaryEntry = false,
                    IsRewatch = false,
                    CreatedAt = new DateTime(2026, 7, 5, 12, 15, 0)
                });
        }

        private static void SeedMovieLists(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<MovieList>().HasData(
                new MovieList
                {
                    Id = 1,
                    UserId = 2,
                    Name = "Watchlist",
                    Description = "Films I still need to get to.",
                    Type = ListType.Watchlist,
                    CreatedAt = new DateTime(2024, 3, 2, 14, 30, 0),
                    UpdatedAt = new DateTime(2026, 7, 10, 9, 15, 0)
                },
                new MovieList
                {
                    Id = 2,
                    UserId = 5,
                    Name = "Watchlist",
                    Description = "Queue, mostly restorations and repertory screenings.",
                    Type = ListType.Watchlist,
                    CreatedAt = new DateTime(2024, 8, 21, 6, 20, 0),
                    UpdatedAt = new DateTime(2026, 6, 30, 18, 0, 0)
                },
                new MovieList
                {
                    Id = 3,
                    UserId = 4,
                    Name = "Films About Films",
                    Description = "Cinema looking at itself, from projection booths to studio backlots.",
                    Type = ListType.Custom,
                    CreatedAt = new DateTime(2025, 4, 12, 15, 0, 0),
                    UpdatedAt = new DateTime(2026, 4, 10, 11, 30, 0)
                },
                new MovieList
                {
                    Id = 4,
                    UserId = 7,
                    Name = "Comfort Watches",
                    Description = "For rainy Sundays when nothing demanding will do.",
                    Type = ListType.Custom,
                    CreatedAt = new DateTime(2025, 6, 18, 20, 10, 0),
                    UpdatedAt = new DateTime(2026, 5, 3, 14, 45, 0)
                },
                new MovieList
                {
                    Id = 5,
                    UserId = 3,
                    Name = "Crime and Consequence",
                    Description = "Films where the crime is the easy part and living with it is not.",
                    Type = ListType.Clash,
                    CreatedAt = new DateTime(2026, 4, 2, 10, 0, 0),
                    UpdatedAt = new DateTime(2026, 4, 5, 16, 20, 0)
                },
                new MovieList
                {
                    Id = 6,
                    UserId = 8,
                    Name = "Class Warfare on Screen",
                    Description = "My entry for the spring clash: films where the real antagonist is the ladder.",
                    Type = ListType.Clash,
                    CreatedAt = new DateTime(2026, 4, 3, 13, 25, 0),
                    UpdatedAt = new DateTime(2026, 4, 6, 9, 50, 0)
                },
                new MovieList
                {
                    Id = 7,
                    UserId = 5,
                    Name = "Practical Effects Only",
                    Description = "No previsualisation, no rendered doubles. Things that were actually built and filmed.",
                    Type = ListType.Clash,
                    CreatedAt = new DateTime(2026, 6, 20, 8, 40, 0),
                    UpdatedAt = new DateTime(2026, 6, 22, 19, 10, 0)
                },
                new MovieList
                {
                    Id = 8,
                    UserId = 9,
                    Name = "Built, Not Rendered",
                    Description = "Stunt work and physical craft, submitted for the summer clash.",
                    Type = ListType.Clash,
                    CreatedAt = new DateTime(2026, 6, 21, 17, 55, 0),
                    UpdatedAt = new DateTime(2026, 6, 23, 12, 5, 0)
                });
        }

        private static void SeedMovieListItems(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<MovieListItem>().HasData(
                // Emma's watchlist
                new MovieListItem { Id = 1, MovieListId = 1, MovieId = 12, Position = 1, AddedAt = new DateTime(2025, 10, 4, 9, 0, 0) },
                new MovieListItem { Id = 2, MovieListId = 1, MovieId = 11, Position = 2, AddedAt = new DateTime(2025, 12, 1, 21, 30, 0) },
                new MovieListItem { Id = 3, MovieListId = 1, MovieId = 8, Position = 3, AddedAt = new DateTime(2026, 3, 14, 11, 45, 0) },
                // Kenji's watchlist
                new MovieListItem { Id = 4, MovieListId = 2, MovieId = 8, Position = 1, AddedAt = new DateTime(2025, 11, 9, 7, 20, 0) },
                new MovieListItem { Id = 5, MovieListId = 2, MovieId = 7, Position = 2, AddedAt = new DateTime(2026, 2, 17, 22, 10, 0) },
                // Films About Films
                new MovieListItem { Id = 6, MovieListId = 3, MovieId = 8, Position = 1, AddedAt = new DateTime(2025, 4, 12, 15, 5, 0) },
                new MovieListItem { Id = 7, MovieListId = 3, MovieId = 9, Position = 2, AddedAt = new DateTime(2025, 8, 30, 18, 40, 0) },
                // Comfort Watches
                new MovieListItem { Id = 8, MovieListId = 4, MovieId = 7, Position = 1, AddedAt = new DateTime(2025, 6, 18, 20, 15, 0) },
                new MovieListItem { Id = 9, MovieListId = 4, MovieId = 3, Position = 2, AddedAt = new DateTime(2025, 9, 7, 13, 25, 0) },
                new MovieListItem { Id = 10, MovieListId = 4, MovieId = 8, Position = 3, AddedAt = new DateTime(2026, 1, 26, 16, 0, 0) },
                // Crime and Consequence (clash entry)
                new MovieListItem { Id = 11, MovieListId = 5, MovieId = 1, Position = 1, AddedAt = new DateTime(2026, 4, 2, 10, 5, 0) },
                new MovieListItem { Id = 12, MovieListId = 5, MovieId = 2, Position = 2, AddedAt = new DateTime(2026, 4, 2, 10, 8, 0) },
                new MovieListItem { Id = 13, MovieListId = 5, MovieId = 6, Position = 3, AddedAt = new DateTime(2026, 4, 2, 10, 12, 0) },
                // Class Warfare on Screen (clash entry)
                new MovieListItem { Id = 14, MovieListId = 6, MovieId = 4, Position = 1, AddedAt = new DateTime(2026, 4, 3, 13, 30, 0) },
                new MovieListItem { Id = 15, MovieListId = 6, MovieId = 1, Position = 2, AddedAt = new DateTime(2026, 4, 3, 13, 34, 0) },
                new MovieListItem { Id = 16, MovieListId = 6, MovieId = 9, Position = 3, AddedAt = new DateTime(2026, 4, 3, 13, 38, 0) },
                // Practical Effects Only (clash entry)
                new MovieListItem { Id = 17, MovieListId = 7, MovieId = 12, Position = 1, AddedAt = new DateTime(2026, 6, 20, 8, 45, 0) },
                new MovieListItem { Id = 18, MovieListId = 7, MovieId = 11, Position = 2, AddedAt = new DateTime(2026, 6, 20, 8, 49, 0) },
                new MovieListItem { Id = 19, MovieListId = 7, MovieId = 10, Position = 3, AddedAt = new DateTime(2026, 6, 20, 8, 52, 0) },
                // Built, Not Rendered (clash entry)
                new MovieListItem { Id = 20, MovieListId = 8, MovieId = 10, Position = 1, AddedAt = new DateTime(2026, 6, 21, 18, 0, 0) },
                new MovieListItem { Id = 21, MovieListId = 8, MovieId = 6, Position = 2, AddedAt = new DateTime(2026, 6, 21, 18, 4, 0) },
                new MovieListItem { Id = 22, MovieListId = 8, MovieId = 5, Position = 3, AddedAt = new DateTime(2026, 6, 21, 18, 7, 0) });
        }

        private static void SeedClashes(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Clash>().HasData(
                new Clash
                {
                    Id = 1,
                    Name = "Spring Clash: Crime and Class",
                    Description = "Build a list of films where money, power or the lack of both drives the story. Three to ten titles, voting opens once submissions close.",
                    Status = ClashStatus.Completed,
                    StartDate = new DateTime(2026, 4, 1, 0, 0, 0),
                    EndDate = new DateTime(2026, 4, 30, 23, 59, 0),
                    CreatedAt = new DateTime(2026, 3, 20, 10, 0, 0)
                },
                new Clash
                {
                    Id = 2,
                    Name = "Summer Clash: Made By Hand",
                    Description = "Practical effects, real stunts, built sets. Submit a list that makes the case for physical filmmaking.",
                    Status = ClashStatus.Active,
                    StartDate = new DateTime(2026, 6, 15, 0, 0, 0),
                    EndDate = new DateTime(2026, 7, 31, 23, 59, 0),
                    CreatedAt = new DateTime(2026, 6, 1, 9, 30, 0)
                },
                new Clash
                {
                    Id = 3,
                    Name = "Autumn Clash: Debut Features",
                    Description = "First films only. Make the case for a director who arrived fully formed.",
                    Status = ClashStatus.Upcoming,
                    StartDate = new DateTime(2026, 9, 1, 0, 0, 0),
                    EndDate = new DateTime(2026, 10, 15, 23, 59, 0),
                    CreatedAt = new DateTime(2026, 7, 10, 14, 20, 0)
                });
        }

        private static void SeedClashEntries(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<ClashEntry>().HasData(
                new ClashEntry { Id = 1, ClashId = 1, UserId = 3, MovieListId = 5, IsWinner = false, CreatedAt = new DateTime(2026, 4, 5, 16, 25, 0) },
                new ClashEntry { Id = 2, ClashId = 1, UserId = 8, MovieListId = 6, IsWinner = true, CreatedAt = new DateTime(2026, 4, 6, 9, 55, 0) },
                new ClashEntry { Id = 3, ClashId = 2, UserId = 5, MovieListId = 7, IsWinner = false, CreatedAt = new DateTime(2026, 6, 22, 19, 15, 0) },
                new ClashEntry { Id = 4, ClashId = 2, UserId = 9, MovieListId = 8, IsWinner = false, CreatedAt = new DateTime(2026, 6, 23, 12, 10, 0) });
        }

        private static void SeedClashVotes(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<ClashVote>().HasData(
                new ClashVote { Id = 1, ClashEntryId = 1, VoterId = 2, CreatedAt = new DateTime(2026, 4, 20, 10, 5, 0) },
                new ClashVote { Id = 2, ClashEntryId = 1, VoterId = 4, CreatedAt = new DateTime(2026, 4, 21, 18, 30, 0) },
                new ClashVote { Id = 3, ClashEntryId = 2, VoterId = 5, CreatedAt = new DateTime(2026, 4, 20, 21, 40, 0) },
                new ClashVote { Id = 4, ClashEntryId = 2, VoterId = 6, CreatedAt = new DateTime(2026, 4, 22, 8, 15, 0) },
                new ClashVote { Id = 5, ClashEntryId = 2, VoterId = 7, CreatedAt = new DateTime(2026, 4, 25, 13, 0, 0) },
                new ClashVote { Id = 6, ClashEntryId = 3, VoterId = 4, CreatedAt = new DateTime(2026, 7, 2, 20, 25, 0) },
                new ClashVote { Id = 7, ClashEntryId = 3, VoterId = 8, CreatedAt = new DateTime(2026, 7, 8, 11, 50, 0) },
                new ClashVote { Id = 8, ClashEntryId = 4, VoterId = 6, CreatedAt = new DateTime(2026, 7, 4, 17, 35, 0) },
                new ClashVote { Id = 9, ClashEntryId = 4, VoterId = 2, CreatedAt = new DateTime(2026, 7, 12, 9, 5, 0) });
        }

        private static void SeedActivities(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Activity>().HasData(
                new Activity { Id = 1, UserId = 2, Type = ActivityType.JoinedPlatform, CreatedAt = new DateTime(2024, 3, 2, 14, 25, 0) },
                new Activity { Id = 2, UserId = 5, Type = ActivityType.JoinedPlatform, CreatedAt = new DateTime(2024, 8, 21, 6, 15, 0) },
                new Activity { Id = 3, UserId = 2, Type = ActivityType.FollowedUser, TargetUserId = 3, CreatedAt = new DateTime(2024, 5, 2, 12, 0, 0) },
                new Activity { Id = 4, UserId = 2, Type = ActivityType.ReviewedMovie, MovieId = 1, ReviewId = 1, CreatedAt = new DateTime(2025, 11, 3, 21, 40, 0) },
                new Activity { Id = 5, UserId = 3, Type = ActivityType.ReviewedMovie, MovieId = 2, ReviewId = 2, CreatedAt = new DateTime(2025, 12, 18, 23, 5, 0) },
                new Activity { Id = 6, UserId = 5, Type = ActivityType.WatchedMovie, MovieId = 3, CreatedAt = new DateTime(2026, 1, 7, 19, 25, 0) },
                new Activity { Id = 7, UserId = 5, Type = ActivityType.ReviewedMovie, MovieId = 3, ReviewId = 3, CreatedAt = new DateTime(2026, 1, 7, 19, 30, 0) },
                new Activity { Id = 8, UserId = 8, Type = ActivityType.LikedMovie, MovieId = 4, CreatedAt = new DateTime(2026, 2, 2, 14, 52, 0) },
                new Activity { Id = 9, UserId = 6, Type = ActivityType.ReviewedMovie, MovieId = 5, ReviewId = 5, CreatedAt = new DateTime(2026, 2, 20, 20, 15, 0) },
                new Activity { Id = 10, UserId = 2, Type = ActivityType.AddedToWatchlist, MovieId = 8, MovieListId = 1, CreatedAt = new DateTime(2026, 3, 14, 11, 45, 0) },
                new Activity { Id = 11, UserId = 3, Type = ActivityType.CreatedList, MovieListId = 5, CreatedAt = new DateTime(2026, 4, 2, 10, 0, 0) },
                new Activity { Id = 12, UserId = 3, Type = ActivityType.JoinedClash, ClashId = 1, MovieListId = 5, CreatedAt = new DateTime(2026, 4, 5, 16, 25, 0) },
                new Activity { Id = 13, UserId = 8, Type = ActivityType.JoinedClash, ClashId = 1, MovieListId = 6, CreatedAt = new DateTime(2026, 4, 6, 9, 55, 0) },
                new Activity { Id = 14, UserId = 8, Type = ActivityType.WonClash, ClashId = 1, MovieListId = 6, CreatedAt = new DateTime(2026, 5, 1, 10, 0, 0) },
                new Activity { Id = 15, UserId = 4, Type = ActivityType.ReviewedMovie, MovieId = 8, ReviewId = 8, CreatedAt = new DateTime(2026, 4, 9, 21, 10, 0) },
                new Activity { Id = 16, UserId = 9, Type = ActivityType.WatchedMovie, MovieId = 10, CreatedAt = new DateTime(2026, 5, 24, 19, 45, 0) },
                new Activity { Id = 17, UserId = 5, Type = ActivityType.CreatedList, MovieListId = 7, CreatedAt = new DateTime(2026, 6, 20, 8, 40, 0) },
                new Activity { Id = 18, UserId = 5, Type = ActivityType.JoinedClash, ClashId = 2, MovieListId = 7, CreatedAt = new DateTime(2026, 6, 22, 19, 15, 0) },
                new Activity { Id = 19, UserId = 9, Type = ActivityType.JoinedClash, ClashId = 2, MovieListId = 8, CreatedAt = new DateTime(2026, 6, 23, 12, 10, 0) },
                new Activity { Id = 20, UserId = 7, Type = ActivityType.RequestedMovie, CreatedAt = new DateTime(2026, 5, 18, 15, 30, 0) });
        }

        private static void SeedMovieRequests(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<MovieRequest>().HasData(
                new MovieRequest
                {
                    Id = 1,
                    RequestedByUserId = 7,
                    CreatedMovieId = 8,
                    Status = MovieRequestStatus.Approved,
                    CreatedAt = new DateTime(2026, 5, 18, 15, 30, 0),
                    ReviewedByUserId = 1,
                    ReviewedAt = new DateTime(2026, 5, 20, 9, 15, 0)
                },
                new MovieRequest
                {
                    Id = 2,
                    RequestedByUserId = 5,
                    CreatedMovieId = 12,
                    Status = MovieRequestStatus.Approved,
                    CreatedAt = new DateTime(2026, 6, 1, 7, 45, 0),
                    ReviewedByUserId = 1,
                    ReviewedAt = new DateTime(2026, 6, 2, 11, 20, 0)
                },
                new MovieRequest
                {
                    Id = 3,
                    RequestedByUserId = 6,
                    Status = MovieRequestStatus.Pending,
                    CreatedAt = new DateTime(2026, 7, 9, 18, 5, 0)
                },
                new MovieRequest
                {
                    Id = 4,
                    RequestedByUserId = 10,
                    Status = MovieRequestStatus.Rejected,
                    CreatedAt = new DateTime(2026, 2, 11, 13, 0, 0),
                    ReviewedByUserId = 1,
                    ReviewedAt = new DateTime(2026, 2, 13, 8, 30, 0)
                });
        }

        private static void SeedMovieIssueReports(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<MovieIssueReport>().HasData(
                new MovieIssueReport
                {
                    Id = 1,
                    MovieId = 7,
                    ReportedByUserId = 7,
                    Description = "The runtime is listed as 122 minutes but the French theatrical cut runs 129. Worth checking which version the entry describes.",
                    Status = ReportStatus.Resolved,
                    CreatedAt = new DateTime(2026, 4, 2, 10, 45, 0),
                    ReviewedByUserId = 1,
                    ResolvedAt = new DateTime(2026, 4, 4, 14, 0, 0),
                    AdminComment = "Verified against the original release. Entry now reflects the international cut, which is the 122 minute version."
                },
                new MovieIssueReport
                {
                    Id = 2,
                    MovieId = 11,
                    ReportedByUserId = 10,
                    Description = "Das Boot exists as a theatrical cut, a director's cut and a television miniseries. The listed duration matches none of them cleanly.",
                    Status = ReportStatus.Open,
                    CreatedAt = new DateTime(2026, 6, 12, 20, 15, 0)
                },
                new MovieIssueReport
                {
                    Id = 3,
                    MovieId = 3,
                    ReportedByUserId = 5,
                    Description = "Trailer link points to the English dub trailer rather than the original Japanese one.",
                    Status = ReportStatus.Open,
                    CreatedAt = new DateTime(2026, 7, 1, 8, 30, 0)
                },
                new MovieIssueReport
                {
                    Id = 4,
                    MovieId = 2,
                    ReportedByUserId = 6,
                    Description = "The description contains a spoiler for the final chapter and should be reworded.",
                    Status = ReportStatus.Dismissed,
                    CreatedAt = new DateTime(2026, 3, 8, 16, 50, 0),
                    ReviewedByUserId = 1,
                    ResolvedAt = new DateTime(2026, 3, 9, 10, 5, 0),
                    AdminComment = "Reviewed the synopsis; it describes the premise only and reveals no plot outcome. No change made."
                });
        }

        private static void SeedUserReports(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<UserReport>().HasData(
                new UserReport
                {
                    Id = 1,
                    ReporterId = 2,
                    ReportedUserId = 10,
                    Reason = "Repeatedly posting unmarked plot spoilers in review comments after being asked to use the spoiler flag.",
                    Status = ReportStatus.Resolved,
                    CreatedAt = new DateTime(2026, 2, 14, 9, 15, 0),
                    ReviewedByUserId = 1,
                    ResolvedAt = new DateTime(2026, 2, 16, 11, 40, 0),
                    AdminComment = "Confirmed across three reviews. Account deactivated pending acknowledgement of the content guidelines."
                },
                new UserReport
                {
                    Id = 2,
                    ReporterId = 9,
                    ReportedUserId = 10,
                    Reason = "Copied the text of another member's review word for word and posted it under their own account.",
                    Status = ReportStatus.Resolved,
                    CreatedAt = new DateTime(2026, 4, 22, 8, 0, 0),
                    ReviewedByUserId = 1,
                    ResolvedAt = new DateTime(2026, 4, 23, 15, 25, 0),
                    AdminComment = "Duplicate review removed. Account already deactivated from the earlier report."
                },
                new UserReport
                {
                    Id = 3,
                    ReporterId = 5,
                    ReportedUserId = 6,
                    Reason = "Hostile replies on a clash entry, including personal remarks unrelated to the films listed.",
                    Status = ReportStatus.Open,
                    CreatedAt = new DateTime(2026, 7, 6, 19, 45, 0)
                },
                new UserReport
                {
                    Id = 4,
                    ReporterId = 6,
                    ReportedUserId = 3,
                    Reason = "Downvoted my clash entry and left a rude comment.",
                    Status = ReportStatus.Dismissed,
                    CreatedAt = new DateTime(2026, 4, 26, 12, 30, 0),
                    ReviewedByUserId = 1,
                    ResolvedAt = new DateTime(2026, 4, 27, 9, 10, 0),
                    AdminComment = "Reviewed the exchange. Disagreement about a list is not a guideline violation and the comment was civil."
                });
        }
    }
}