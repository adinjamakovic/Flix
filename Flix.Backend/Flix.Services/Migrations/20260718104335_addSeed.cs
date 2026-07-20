using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Flix.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class addSeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Clashes",
                columns: new[] { "Id", "BannerImageBase64", "CreatedAt", "Description", "EndDate", "Name", "StartDate", "Status" },
                values: new object[,]
                {
                    { 1, null, new DateTime(2026, 3, 20, 10, 0, 0, 0, DateTimeKind.Unspecified), "Build a list of films where money, power or the lack of both drives the story. Three to ten titles, voting opens once submissions close.", new DateTime(2026, 4, 30, 23, 59, 0, 0, DateTimeKind.Unspecified), "Spring Clash: Crime and Class", new DateTime(2026, 4, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 2 },
                    { 2, null, new DateTime(2026, 6, 1, 9, 30, 0, 0, DateTimeKind.Unspecified), "Practical effects, real stunts, built sets. Submit a list that makes the case for physical filmmaking.", new DateTime(2026, 7, 31, 23, 59, 0, 0, DateTimeKind.Unspecified), "Summer Clash: Made By Hand", new DateTime(2026, 6, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), 1 },
                    { 3, null, new DateTime(2026, 7, 10, 14, 20, 0, 0, DateTimeKind.Unspecified), "First films only. Make the case for a director who arrived fully formed.", new DateTime(2026, 10, 15, 23, 59, 0, 0, DateTimeKind.Unspecified), "Autumn Clash: Debut Features", new DateTime(2026, 9, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 0 }
                });

            migrationBuilder.InsertData(
                table: "Countries",
                columns: new[] { "Id", "Code", "FlagImageBase64", "Name" },
                values: new object[,]
                {
                    { 1, "US", null, "United States" },
                    { 2, "GB", null, "United Kingdom" },
                    { 3, "JP", null, "Japan" },
                    { 4, "FR", null, "France" },
                    { 5, "KR", null, "South Korea" },
                    { 6, "DE", null, "Germany" },
                    { 7, "IT", null, "Italy" },
                    { 8, "CA", null, "Canada" },
                    { 9, "AU", null, "Australia" },
                    { 10, "BA", null, "Bosnia and Herzegovina" },
                    { 11, "MY", null, "Malaysia" },
                    { 12, "VN", null, "Vietnam" },
                    { 13, "ZA", null, "South Africa" }
                });

            migrationBuilder.InsertData(
                table: "Genres",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Action" },
                    { 2, "Adventure" },
                    { 3, "Animation" },
                    { 4, "Comedy" },
                    { 5, "Crime" },
                    { 6, "Drama" },
                    { 7, "Fantasy" },
                    { 8, "Horror" },
                    { 9, "Mystery" },
                    { 10, "Romance" },
                    { 11, "Science Fiction" },
                    { 12, "Thriller" }
                });

            migrationBuilder.InsertData(
                table: "Languages",
                columns: new[] { "Id", "Code", "Name" },
                values: new object[,]
                {
                    { 1, "en", "English" },
                    { 2, "ja", "Japanese" },
                    { 3, "fr", "French" },
                    { 4, "ko", "Korean" },
                    { 5, "de", "German" },
                    { 6, "it", "Italian" },
                    { 7, "es", "Spanish" },
                    { 8, "bs", "Bosnian" }
                });

            migrationBuilder.InsertData(
                table: "Studio",
                columns: new[] { "Id", "Description", "LogoBase64", "Name" },
                values: new object[,]
                {
                    { 1, "Hollywood studio founded in 1912 and the oldest still operating in the United States.", null, "Paramount Pictures" },
                    { 2, "American production and distribution company founded in 1979, known for independent cinema.", null, "Miramax" },
                    { 3, "Japanese animation studio founded in 1985 in Koganei, Tokyo by Hayao Miyazaki, Isao Takahata and Toshio Suzuki.", null, "Studio Ghibli" },
                    { 4, "South Korean film production company based in Seoul, producer of Bong Joon-ho's Parasite.", null, "Barunson E&A" },
                    { 5, "American film studio founded in 1923, headquartered in Burbank, California.", null, "Warner Bros. Pictures" },
                    { 6, "American film studio founded in 1912, a division of NBCUniversal.", null, "Universal Pictures" },
                    { 7, "American independent entertainment company founded in 2012 in New York City.", null, "A24" },
                    { 8, "Japanese film studio founded in 1932, distributor of the Godzilla franchise and Studio Ghibli releases.", null, "Toho" },
                    { 9, "Australian production company founded in Sydney by George Miller and Byron Kennedy.", null, "Kennedy Miller Mitchell" },
                    { 10, "German film production company based in Grunwald near Munich, founded in 1919.", null, "Bavaria Film" }
                });

            migrationBuilder.InsertData(
                table: "CastMembers",
                columns: new[] { "Id", "Biography", "BirthDate", "CountryId", "FirstName", "LastName", "PhotoBase64" },
                values: new object[,]
                {
                    { 1, "American actor whose work with the Actors Studio reshaped screen performance, best known for A Streetcar Named Desire, On the Waterfront and The Godfather.", new DateTime(1924, 4, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "Marlon", "Brando", null },
                    { 2, "American actor from East Harlem, New York, who rose to fame as Michael Corleone and went on to star in Serpico, Scarface and Heat.", new DateTime(1940, 4, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "Al", "Pacino", null },
                    { 3, "American director and screenwriter, a central figure of New Hollywood, who directed The Godfather trilogy and Apocalypse Now.", new DateTime(1939, 4, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "Francis Ford", "Coppola", null },
                    { 4, "American actor and dancer who broke through with Saturday Night Fever and Grease before his career revival in Pulp Fiction.", new DateTime(1954, 2, 18, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "John", "Travolta", null },
                    { 5, "American actor raised in Chattanooga, Tennessee, and one of the highest-grossing performers in film history.", new DateTime(1948, 12, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "Samuel L.", "Jackson", null },
                    { 6, "American director and screenwriter known for non-linear storytelling in Reservoir Dogs, Pulp Fiction and Kill Bill.", new DateTime(1963, 3, 27, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "Quentin", "Tarantino", null },
                    { 7, "Japanese animator and director, co-founder of Studio Ghibli and creator of My Neighbour Totoro, Princess Mononoke and Spirited Away.", new DateTime(1941, 1, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, "Hayao", "Miyazaki", null },
                    { 8, "Japanese actress who voiced Chihiro in Spirited Away at the age of thirteen.", new DateTime(1987, 8, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, "Rumi", "Hiiragi", null },
                    { 9, "South Korean director and screenwriter whose films Memories of Murder, The Host and Parasite blend genre with social critique.", new DateTime(1969, 9, 14, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, "Bong", "Joon-ho", null },
                    { 10, "South Korean actor and frequent Bong Joon-ho collaborator, winner of Best Actor at Cannes for Broker.", new DateTime(1967, 1, 17, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, "Song", "Kang-ho", null },
                    { 11, "British-American director known for Memento, The Dark Knight trilogy, Inception, Interstellar and Oppenheimer.", new DateTime(1970, 7, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, "Christopher", "Nolan", null },
                    { 12, "American actor and environmental activist known for Titanic, The Departed, Inception and The Revenant.", new DateTime(1974, 11, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "Leonardo", "DiCaprio", null },
                    { 13, "Welsh actor known for extreme physical transformations in American Psycho, The Machinist and The Dark Knight trilogy.", new DateTime(1974, 1, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, "Christian", "Bale", null },
                    { 14, "Australian actor from Perth whose performance as the Joker in The Dark Knight earned a posthumous Academy Award.", new DateTime(1979, 4, 4, 0, 0, 0, 0, DateTimeKind.Unspecified), 9, "Heath", "Ledger", null },
                    { 15, "French director known for the distinctive visual style of Delicatessen, The City of Lost Children and Amelie.", new DateTime(1953, 9, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, "Jean-Pierre", "Jeunet", null },
                    { 16, "French actress who became internationally known as the title character in Amelie and later starred in A Very Long Engagement.", new DateTime(1976, 8, 9, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, "Audrey", "Tautou", null },
                    { 17, "Italian director from Bagheria, Sicily, whose Cinema Paradiso won the Academy Award for Best Foreign Language Film.", new DateTime(1956, 5, 27, 0, 0, 0, 0, DateTimeKind.Unspecified), 7, "Giuseppe", "Tornatore", null },
                    { 18, "French actor of stage and screen who appeared in more than a hundred films, including Cinema Paradiso and Il Postino.", new DateTime(1930, 10, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, "Philippe", "Noiret", null },
                    { 19, "Malaysian actress known for Hong Kong action cinema, Crouching Tiger, Hidden Dragon and her Academy Award-winning role in Everything Everywhere All at Once.", new DateTime(1962, 8, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), 11, "Michelle", "Yeoh", null },
                    { 20, "Vietnamese-born American actor who starred as a child in Indiana Jones and the Temple of Doom and The Goonies before his return in Everything Everywhere All at Once.", new DateTime(1971, 8, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), 12, "Ke Huy", "Quan", null },
                    { 21, "American director and one half of the duo Daniels, co-director of Swiss Army Man and Everything Everywhere All at Once.", new DateTime(1988, 2, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "Daniel", "Kwan", null },
                    { 22, "Australian director and former medical doctor who created the Mad Max series and directed Babe and Happy Feet.", new DateTime(1945, 3, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), 9, "George", "Miller", null },
                    { 23, "South African-American actress and producer who won an Academy Award for Monster and starred as Furiosa in Mad Max: Fury Road.", new DateTime(1975, 8, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), 13, "Charlize", "Theron", null },
                    { 24, "English actor known for Bronson, Inception, Mad Max: Fury Road and the Venom films.", new DateTime(1977, 9, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, "Tom", "Hardy", null },
                    { 25, "German director who broke through with Das Boot and went on to make The NeverEnding Story, Air Force One and Troy.", new DateTime(1941, 3, 14, 0, 0, 0, 0, DateTimeKind.Unspecified), 6, "Wolfgang", "Petersen", null },
                    { 26, "German actor best known internationally as the U-boat captain in Das Boot.", new DateTime(1941, 6, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 6, "Jurgen", "Prochnow", null },
                    { 27, "Japanese director whose Rashomon, Seven Samurai and Ran made him one of the most influential filmmakers in cinema history.", new DateTime(1910, 3, 23, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, "Akira", "Kurosawa", null },
                    { 28, "Japanese actor who appeared in sixteen films with Akira Kurosawa, among them Seven Samurai, Yojimbo and Throne of Blood.", new DateTime(1920, 4, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, "Toshiro", "Mifune", null }
                });

            migrationBuilder.InsertData(
                table: "Movies",
                columns: new[] { "Id", "CountryId", "Description", "DurationMinutes", "HeaderImageBase64", "IsEnabled", "LanguageId", "PosterBase64", "ReleaseDate", "Title", "TrailerUrl", "Views" },
                values: new object[,]
                {
                    { 1, 1, "The ageing patriarch of an organised crime dynasty transfers control of his clandestine empire to his reluctant youngest son.", 175, null, true, 1, null, new DateTime(1972, 3, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), "The Godfather", "https://www.youtube.com/watch?v=sY1S34973zA", 184320 },
                    { 2, 1, "The lives of two mob hitmen, a boxer, a gangster's wife and a pair of diner bandits intertwine in four tales of violence and redemption.", 154, null, true, 1, null, new DateTime(1994, 10, 14, 0, 0, 0, 0, DateTimeKind.Unspecified), "Pulp Fiction", "https://www.youtube.com/watch?v=s7EdQ4FqbhY", 167845 },
                    { 3, 3, "During her family's move to the suburbs, a sullen ten-year-old girl wanders into a world ruled by gods, witches and spirits where humans are changed into beasts.", 125, null, true, 2, null, new DateTime(2001, 7, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "Spirited Away", "https://www.youtube.com/watch?v=ByXuk9QqQkk", 142190 },
                    { 4, 5, "Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the destitute Kim clan.", 132, null, true, 4, null, new DateTime(2019, 5, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), "Parasite", "https://www.youtube.com/watch?v=5xH0HfJHsaY", 158073 },
                    { 5, 1, "A thief who steals corporate secrets through dream-sharing technology is given the inverse task of planting an idea into the mind of a chief executive.", 148, null, true, 1, null, new DateTime(2010, 7, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), "Inception", "https://www.youtube.com/watch?v=YoHD9XEInc0", 203557 },
                    { 6, 1, "Batman raises the stakes in his war on crime until a rising criminal mastermind known as the Joker forces Gotham into anarchy.", 152, null, true, 1, null, new DateTime(2008, 7, 18, 0, 0, 0, 0, DateTimeKind.Unspecified), "The Dark Knight", "https://www.youtube.com/watch?v=EXeTwQWrcwY", 221408 },
                    { 7, 4, "A shy waitress in Montmartre decides to change the lives of those around her for the better while struggling with her own isolation.", 122, null, true, 3, null, new DateTime(2001, 4, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Amelie", "https://www.youtube.com/watch?v=HUECWi5pX7o", 96412 },
                    { 8, 7, "A filmmaker recalls his childhood in a Sicilian village and the friendship with the projectionist who taught him to love the movies.", 155, null, true, 6, null, new DateTime(1988, 11, 17, 0, 0, 0, 0, DateTimeKind.Unspecified), "Cinema Paradiso", "https://www.youtube.com/watch?v=Ah0kPnzzrs4", 74265 },
                    { 9, 1, "An overwhelmed laundromat owner facing an audit discovers she must connect with parallel versions of herself to stop a threat spanning the multiverse.", 139, null, true, 1, null, new DateTime(2022, 3, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Everything Everywhere All at Once", "https://www.youtube.com/watch?v=wxN1T1uxQ2g", 131776 },
                    { 10, 9, "In a post-apocalyptic wasteland, a drifter and a rebel warrior flee from a tyrant and his war parties in a relentless convoy chase.", 120, null, true, 1, null, new DateTime(2015, 5, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "Mad Max: Fury Road", "https://www.youtube.com/watch?v=hEJnMQG9ev8", 148903 },
                    { 11, 6, "The claustrophobic patrol of a German U-boat crew in the Atlantic during the Second World War, told from inside the submarine.", 149, null, true, 5, null, new DateTime(1981, 9, 17, 0, 0, 0, 0, DateTimeKind.Unspecified), "Das Boot", "https://www.youtube.com/watch?v=zTaS7OFHM6M", 52338 },
                    { 12, 3, "A poor village under attack by bandits recruits seven masterless samurai to help them defend themselves.", 207, null, true, 2, null, new DateTime(1954, 4, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), "Seven Samurai", "https://www.youtube.com/watch?v=wErvXaYtDGE", 68150 }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Bio", "CountryId", "CreatedAt", "Email", "FirstName", "IsActive", "IsAdmin", "LastLoginAt", "LastName", "PasswordHash", "PasswordSalt", "PhoneNumber", "ProfileImageBase64", "Username" },
                values: new object[,]
                {
                    { 1, "Platform maintainer. Somewhere between a Kurosawa retrospective and the next release.", 10, new DateTime(2024, 1, 15, 9, 0, 0, 0, DateTimeKind.Unspecified), "adin.jamakovic@flix.app", "Adin", true, true, new DateTime(2026, 7, 16, 8, 42, 0, 0, DateTimeKind.Unspecified), "Jamakovic", "rHD2Yh73AE02oeak4nQOAzToFyW1gjxDH1Z4lfv+ChI=", "c2FsdF91c2VyXzAxMjM0NQ==", "+387 61 234 567", null, "adin.jamakovic" },
                    { 2, "Film studies graduate in Manchester. Partial to slow cinema and anything shot on 35mm.", 2, new DateTime(2024, 3, 2, 14, 25, 0, 0, DateTimeKind.Unspecified), "emma.clarke@gmail.com", "Emma", true, false, new DateTime(2026, 7, 15, 20, 11, 0, 0, DateTimeKind.Unspecified), "Clarke", "0NKgFZKMHKecbrVPU9chw7ICV923UYEBgrszYQB/Auk=", "c2FsdF91c2VyXzAyMzQ1Ng==", "+44 7700 900412", null, "emmaclarke" },
                    { 3, "Toronto-based editor. I keep a diary of every rewatch, which is probably too many.", 8, new DateTime(2024, 4, 18, 11, 5, 0, 0, DateTimeKind.Unspecified), "liam.novak@outlook.com", "Liam", true, false, new DateTime(2026, 7, 14, 19, 30, 0, 0, DateTimeKind.Unspecified), "Novak", "HG93pIZwDVehedrtudgmNqn5FXRmL6DTZl/Vbzh8V7Y=", "c2FsdF91c2VyXzAzNDU2Nw==", "+1 416 555 0148", null, "liamnovak" },
                    { 4, "From Bologna. Italian neorealism first, everything else after.", 7, new DateTime(2024, 6, 9, 17, 48, 0, 0, DateTimeKind.Unspecified), "sofia.rossi@libero.it", "Sofia", true, false, new DateTime(2026, 7, 17, 10, 3, 0, 0, DateTimeKind.Unspecified), "Rossi", "QMoCRAuTRA4kgSH7W2ifOLkdcsFuLYavdLC0z/TO3KU=", "c2FsdF91c2VyXzA0NTY3OA==", "+39 320 555 0119", null, "sofiarossi" },
                    { 5, "Osaka. Ghibli completionist, Kurosawa apologist, occasional subtitler.", 3, new DateTime(2024, 8, 21, 6, 15, 0, 0, DateTimeKind.Unspecified), "kenji.tanaka@yahoo.co.jp", "Kenji", true, false, new DateTime(2026, 7, 17, 22, 55, 0, 0, DateTimeKind.Unspecified), "Tanaka", "l70pUC0q+1w9rcqVXxAk6ZQs1N6IaZAWw3KK5OLx+bE=", "c2FsdF91c2VyXzA1Njc4OQ==", "+81 90 1234 5678", null, "kenjitanaka" },
                    { 6, "Austin, Texas. Blockbusters on the biggest screen I can find.", 1, new DateTime(2024, 10, 4, 13, 40, 0, 0, DateTimeKind.Unspecified), "marcus.webb@protonmail.com", "Marcus", true, false, new DateTime(2026, 7, 12, 16, 20, 0, 0, DateTimeKind.Unspecified), "Webb", "OavnspkOZwNRsdv1VTWmMq83+HJJeZ6z43huQXc8bnY=", "c2FsdF91c2VyXzA2Nzg5MA==", "+1 512 555 0173", null, "marcuswebb" },
                    { 7, "Lyon. I make lists far more often than I finish them.", 4, new DateTime(2025, 1, 12, 8, 55, 0, 0, DateTimeKind.Unspecified), "chloe.dubois@orange.fr", "Chloe", true, false, new DateTime(2026, 7, 16, 12, 47, 0, 0, DateTimeKind.Unspecified), "Dubois", "7NSJsmuMeW7SwJXhQS3Lgmvj9srSZWke+pS1LSDzc84=", "c2FsdF91c2VyXzA3ODkwMQ==", "+33 6 12 34 56 78", null, "chloedubois" },
                    { 8, "Seoul. Genre cinema, thrillers, and arguing about endings.", 5, new DateTime(2025, 2, 27, 21, 10, 0, 0, DateTimeKind.Unspecified), "daniel.kim@naver.com", "Daniel", true, false, new DateTime(2026, 7, 17, 7, 5, 0, 0, DateTimeKind.Unspecified), "Kim", "ibSjrpZ3IdWS5fZWW9sQcGffMXvrCQTWSqr1NT5vUFc=", "c2FsdF91c2VyXzA4OTAxMg==", "+82 10 9876 5432", null, "danielkim" },
                    { 9, "Melbourne. Australian cinema, practical effects, and a soft spot for road movies.", 9, new DateTime(2025, 5, 6, 15, 30, 0, 0, DateTimeKind.Unspecified), "amelia.hughes@gmail.com", "Amelia", true, false, new DateTime(2026, 7, 11, 18, 22, 0, 0, DateTimeKind.Unspecified), "Hughes", "M0+tSbxsqqz4MCSJ6BSAsS26awb3Z15PGfbr1UGCZOw=", "c2FsdF91c2VyXzA5MDEyMw==", "+61 4 1234 5678", null, "ameliahughes" },
                    { 10, "Hamburg. Account on hold while I finish my thesis on post-war German film.", 6, new DateTime(2025, 9, 19, 10, 12, 0, 0, DateTimeKind.Unspecified), "noah.fischer@web.de", "Noah", false, false, new DateTime(2026, 3, 28, 9, 41, 0, 0, DateTimeKind.Unspecified), "Fischer", "B5YC1xf276jA12l+Nv+cGjo52IrXkCBl58sz/rIKOBo=", "c2FsdF91c2VyXzEwMTIzNA==", "+49 151 23456789", null, "noahfischer" }
                });

            migrationBuilder.InsertData(
                table: "Activities",
                columns: new[] { "Id", "ClashId", "CreatedAt", "MovieId", "MovieListId", "ReviewId", "TargetUserId", "Type", "UserId" },
                values: new object[,]
                {
                    { 1, null, new DateTime(2024, 3, 2, 14, 25, 0, 0, DateTimeKind.Unspecified), null, null, null, null, 0, 2 },
                    { 2, null, new DateTime(2024, 8, 21, 6, 15, 0, 0, DateTimeKind.Unspecified), null, null, null, null, 0, 5 },
                    { 3, null, new DateTime(2024, 5, 2, 12, 0, 0, 0, DateTimeKind.Unspecified), null, null, null, 3, 6, 2 },
                    { 6, null, new DateTime(2026, 1, 7, 19, 25, 0, 0, DateTimeKind.Unspecified), 3, null, null, null, 1, 5 },
                    { 8, null, new DateTime(2026, 2, 2, 14, 52, 0, 0, DateTimeKind.Unspecified), 4, null, null, null, 3, 8 },
                    { 16, null, new DateTime(2026, 5, 24, 19, 45, 0, 0, DateTimeKind.Unspecified), 10, null, null, null, 1, 9 },
                    { 20, null, new DateTime(2026, 5, 18, 15, 30, 0, 0, DateTimeKind.Unspecified), null, null, null, null, 7, 7 }
                });

            migrationBuilder.InsertData(
                table: "MovieCasts",
                columns: new[] { "Id", "CastMemberId", "CharacterName", "MovieId", "OrderOfAppearence", "Role" },
                values: new object[,]
                {
                    { 1, 3, null, 1, 0, 1 },
                    { 2, 1, "Don Vito Corleone", 1, 1, 0 },
                    { 3, 2, "Michael Corleone", 1, 2, 0 },
                    { 4, 6, null, 2, 0, 1 },
                    { 5, 4, "Vincent Vega", 2, 1, 0 },
                    { 6, 5, "Jules Winnfield", 2, 2, 0 },
                    { 7, 7, null, 3, 0, 1 },
                    { 8, 8, "Chihiro Ogino", 3, 1, 0 },
                    { 9, 9, null, 4, 0, 1 },
                    { 10, 10, "Kim Ki-taek", 4, 1, 0 },
                    { 11, 11, null, 5, 0, 1 },
                    { 12, 12, "Dom Cobb", 5, 1, 0 },
                    { 13, 24, "Eames", 5, 2, 0 },
                    { 14, 11, null, 6, 0, 1 },
                    { 15, 13, "Bruce Wayne / Batman", 6, 1, 0 },
                    { 16, 14, "The Joker", 6, 2, 0 },
                    { 17, 15, null, 7, 0, 1 },
                    { 18, 16, "Amelie Poulain", 7, 1, 0 },
                    { 19, 17, null, 8, 0, 1 },
                    { 20, 18, "Alfredo", 8, 1, 0 },
                    { 21, 21, null, 9, 0, 1 },
                    { 22, 19, "Evelyn Quan Wang", 9, 1, 0 },
                    { 23, 20, "Waymond Wang", 9, 2, 0 },
                    { 24, 22, null, 10, 0, 1 },
                    { 25, 24, "Max Rockatansky", 10, 1, 0 },
                    { 26, 23, "Imperator Furiosa", 10, 2, 0 },
                    { 27, 25, null, 11, 0, 1 },
                    { 28, 26, "Der Kaleun", 11, 1, 0 },
                    { 29, 27, null, 12, 0, 1 },
                    { 30, 28, "Kikuchiyo", 12, 1, 0 }
                });

            migrationBuilder.InsertData(
                table: "MovieGenres",
                columns: new[] { "Id", "GenreId", "MovieId" },
                values: new object[,]
                {
                    { 1, 5, 1 },
                    { 2, 6, 1 },
                    { 3, 5, 2 },
                    { 4, 6, 2 },
                    { 5, 12, 2 },
                    { 6, 3, 3 },
                    { 7, 2, 3 },
                    { 8, 7, 3 },
                    { 9, 6, 4 },
                    { 10, 12, 4 },
                    { 11, 4, 4 },
                    { 12, 1, 5 },
                    { 13, 11, 5 },
                    { 14, 12, 5 },
                    { 15, 1, 6 },
                    { 16, 5, 6 },
                    { 17, 6, 6 },
                    { 18, 4, 7 },
                    { 19, 10, 7 },
                    { 20, 6, 8 },
                    { 21, 10, 8 },
                    { 22, 1, 9 },
                    { 23, 2, 9 },
                    { 24, 11, 9 },
                    { 25, 1, 10 },
                    { 26, 2, 10 },
                    { 27, 11, 10 },
                    { 28, 6, 11 },
                    { 29, 12, 11 },
                    { 30, 1, 12 },
                    { 31, 2, 12 },
                    { 32, 6, 12 }
                });

            migrationBuilder.InsertData(
                table: "MovieIssueReports",
                columns: new[] { "Id", "AdminComment", "CreatedAt", "Description", "MovieId", "ReportedByUserId", "ResolvedAt", "ReviewedByUserId", "Status" },
                values: new object[,]
                {
                    { 1, "Verified against the original release. Entry now reflects the international cut, which is the 122 minute version.", new DateTime(2026, 4, 2, 10, 45, 0, 0, DateTimeKind.Unspecified), "The runtime is listed as 122 minutes but the French theatrical cut runs 129. Worth checking which version the entry describes.", 7, 7, new DateTime(2026, 4, 4, 14, 0, 0, 0, DateTimeKind.Unspecified), 1, 1 },
                    { 2, null, new DateTime(2026, 6, 12, 20, 15, 0, 0, DateTimeKind.Unspecified), "Das Boot exists as a theatrical cut, a director's cut and a television miniseries. The listed duration matches none of them cleanly.", 11, 10, null, null, 0 },
                    { 3, null, new DateTime(2026, 7, 1, 8, 30, 0, 0, DateTimeKind.Unspecified), "Trailer link points to the English dub trailer rather than the original Japanese one.", 3, 5, null, null, 0 },
                    { 4, "Reviewed the synopsis; it describes the premise only and reveals no plot outcome. No change made.", new DateTime(2026, 3, 8, 16, 50, 0, 0, DateTimeKind.Unspecified), "The description contains a spoiler for the final chapter and should be reworded.", 2, 6, new DateTime(2026, 3, 9, 10, 5, 0, 0, DateTimeKind.Unspecified), 1, 2 }
                });

            migrationBuilder.InsertData(
                table: "MovieLists",
                columns: new[] { "Id", "CreatedAt", "Description", "Name", "Type", "UpdatedAt", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2024, 3, 2, 14, 30, 0, 0, DateTimeKind.Unspecified), "Films I still need to get to.", "Watchlist", 1, new DateTime(2026, 7, 10, 9, 15, 0, 0, DateTimeKind.Unspecified), 2 },
                    { 2, new DateTime(2024, 8, 21, 6, 20, 0, 0, DateTimeKind.Unspecified), "Queue, mostly restorations and repertory screenings.", "Watchlist", 1, new DateTime(2026, 6, 30, 18, 0, 0, 0, DateTimeKind.Unspecified), 5 },
                    { 3, new DateTime(2025, 4, 12, 15, 0, 0, 0, DateTimeKind.Unspecified), "Cinema looking at itself, from projection booths to studio backlots.", "Films About Films", 0, new DateTime(2026, 4, 10, 11, 30, 0, 0, DateTimeKind.Unspecified), 4 },
                    { 4, new DateTime(2025, 6, 18, 20, 10, 0, 0, DateTimeKind.Unspecified), "For rainy Sundays when nothing demanding will do.", "Comfort Watches", 0, new DateTime(2026, 5, 3, 14, 45, 0, 0, DateTimeKind.Unspecified), 7 },
                    { 5, new DateTime(2026, 4, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), "Films where the crime is the easy part and living with it is not.", "Crime and Consequence", 2, new DateTime(2026, 4, 5, 16, 20, 0, 0, DateTimeKind.Unspecified), 3 },
                    { 6, new DateTime(2026, 4, 3, 13, 25, 0, 0, DateTimeKind.Unspecified), "My entry for the spring clash: films where the real antagonist is the ladder.", "Class Warfare on Screen", 2, new DateTime(2026, 4, 6, 9, 50, 0, 0, DateTimeKind.Unspecified), 8 },
                    { 7, new DateTime(2026, 6, 20, 8, 40, 0, 0, DateTimeKind.Unspecified), "No previsualisation, no rendered doubles. Things that were actually built and filmed.", "Practical Effects Only", 2, new DateTime(2026, 6, 22, 19, 10, 0, 0, DateTimeKind.Unspecified), 5 },
                    { 8, new DateTime(2026, 6, 21, 17, 55, 0, 0, DateTimeKind.Unspecified), "Stunt work and physical craft, submitted for the summer clash.", "Built, Not Rendered", 2, new DateTime(2026, 6, 23, 12, 5, 0, 0, DateTimeKind.Unspecified), 9 }
                });

            migrationBuilder.InsertData(
                table: "MovieRequests",
                columns: new[] { "Id", "CreatedAt", "CreatedMovieId", "RequestedByUserId", "ReviewedAt", "ReviewedByUserId", "Status" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 5, 18, 15, 30, 0, 0, DateTimeKind.Unspecified), 8, 7, new DateTime(2026, 5, 20, 9, 15, 0, 0, DateTimeKind.Unspecified), 1, 1 },
                    { 2, new DateTime(2026, 6, 1, 7, 45, 0, 0, DateTimeKind.Unspecified), 12, 5, new DateTime(2026, 6, 2, 11, 20, 0, 0, DateTimeKind.Unspecified), 1, 1 },
                    { 3, new DateTime(2026, 7, 9, 18, 5, 0, 0, DateTimeKind.Unspecified), null, 6, null, null, 0 },
                    { 4, new DateTime(2026, 2, 11, 13, 0, 0, 0, DateTimeKind.Unspecified), null, 10, new DateTime(2026, 2, 13, 8, 30, 0, 0, DateTimeKind.Unspecified), 1, 2 }
                });

            migrationBuilder.InsertData(
                table: "MovieStudio",
                columns: new[] { "Id", "MovieId", "StudioId" },
                values: new object[,]
                {
                    { 1, 1, 1 },
                    { 2, 2, 2 },
                    { 3, 3, 3 },
                    { 4, 3, 8 },
                    { 5, 4, 4 },
                    { 6, 5, 5 },
                    { 7, 6, 5 },
                    { 8, 7, 2 },
                    { 9, 8, 2 },
                    { 10, 9, 7 },
                    { 11, 10, 5 },
                    { 12, 10, 9 },
                    { 13, 11, 10 },
                    { 14, 12, 8 }
                });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "Id", "ContainsSpoilers", "Content", "CreatedAt", "IsDiaryEntry", "IsLiked", "IsRewatch", "MovieId", "Rating", "UpdatedAt", "UserId" },
                values: new object[,]
                {
                    { 1, false, "The pacing is unhurried in a way films rarely risk now. Every scene at the Corleone table does double duty as family drama and power broking, and Brando plays authority as exhaustion rather than menace.", new DateTime(2025, 11, 3, 21, 40, 0, 0, DateTimeKind.Unspecified), false, true, true, 1, 5.0m, null, 2 },
                    { 2, false, "Third rewatch and the structure still holds. The diner bookends work because the middle chapters earn them, not because the trick is clever.", new DateTime(2025, 12, 18, 23, 5, 0, 0, DateTimeKind.Unspecified), true, true, true, 2, 4.5m, null, 3 },
                    { 3, false, "Watched it again with my daughter. The bathhouse sequence has more invention in ten minutes than most films manage in two hours, and none of it is explained to you.", new DateTime(2026, 1, 7, 19, 25, 0, 0, DateTimeKind.Unspecified), true, true, true, 3, 5.0m, new DateTime(2026, 1, 8, 8, 10, 0, 0, DateTimeKind.Unspecified), 5 },
                    { 4, true, "The tonal turn halfway through is the whole point, and it lands because the first hour is played as comedy without condescension. The basement reveal reframes every earlier scene.", new DateTime(2026, 2, 2, 14, 50, 0, 0, DateTimeKind.Unspecified), false, true, false, 4, 5.0m, null, 8 },
                    { 5, false, "Structurally ambitious and beautifully staged, though the emotional core never quite matches the ingenuity of the mechanics. The hallway fight is still unmatched.", new DateTime(2026, 2, 20, 20, 15, 0, 0, DateTimeKind.Unspecified), false, true, false, 5, 4.0m, null, 6 },
                    { 6, false, "Ledger reorganises the film around himself every time he appears. The ferry sequence is the closest a blockbuster has come to an honest moral argument.", new DateTime(2026, 3, 5, 22, 30, 0, 0, DateTimeKind.Unspecified), false, true, true, 6, 4.5m, null, 6 },
                    { 7, false, "Saw it again at a repertory screening in Lyon. The saturated palette should be exhausting and somehow never is. Tautou carries the whole thing on small gestures.", new DateTime(2026, 3, 21, 18, 0, 0, 0, DateTimeKind.Unspecified), true, true, true, 7, 4.5m, null, 7 },
                    { 8, true, "My grandfather ran a projector in a village not unlike this one. The final reel is sentimental and I do not care in the slightest.", new DateTime(2026, 4, 9, 21, 10, 0, 0, DateTimeKind.Unspecified), false, true, false, 8, 5.0m, null, 4 },
                    { 9, false, "Maximalist to a fault, but the editing is doing genuinely new things and the mother-daughter thread survives the chaos intact. Yeoh is extraordinary.", new DateTime(2026, 5, 2, 16, 35, 0, 0, DateTimeKind.Unspecified), false, true, false, 9, 4.0m, null, 3 },
                    { 10, false, "Practical stunts, real dust, minimal dialogue. Miller cuts on movement so consistently that the geography of the chase is never once confusing.", new DateTime(2026, 5, 24, 20, 5, 0, 0, DateTimeKind.Unspecified), true, true, false, 10, 4.5m, null, 9 },
                    { 11, false, "The sound design does most of the work. Long stretches of nothing but hull noise and breathing, and it is more tense than any action sequence.", new DateTime(2026, 1, 30, 22, 45, 0, 0, DateTimeKind.Unspecified), false, true, false, 11, 4.5m, null, 10 },
                    { 12, false, "Every action film since has borrowed from the final battle in the rain. What holds up better is the first hour of recruitment, which is patient character work and nothing else.", new DateTime(2026, 6, 14, 17, 20, 0, 0, DateTimeKind.Unspecified), false, true, true, 12, 5.0m, new DateTime(2026, 6, 15, 9, 0, 0, 0, DateTimeKind.Unspecified), 5 },
                    { 13, false, "Impeccably controlled, though I found the final act tips into a register the rest of the film had been careful to avoid.", new DateTime(2026, 6, 28, 19, 55, 0, 0, DateTimeKind.Unspecified), false, true, false, 4, 4.0m, null, 2 },
                    { 14, true, "Excellent villain, overlong third act. The Two-Face material would have been a better film on its own than a coda to this one.", new DateTime(2026, 7, 5, 12, 15, 0, 0, DateTimeKind.Unspecified), false, false, false, 6, 3.5m, null, 8 }
                });

            migrationBuilder.InsertData(
                table: "UserBlocks",
                columns: new[] { "Id", "BlockedId", "BlockerId", "CreatedAt" },
                values: new object[,]
                {
                    { 1, 10, 2, new DateTime(2026, 2, 14, 9, 20, 0, 0, DateTimeKind.Unspecified) },
                    { 2, 6, 5, new DateTime(2026, 3, 30, 17, 45, 0, 0, DateTimeKind.Unspecified) },
                    { 3, 10, 9, new DateTime(2026, 4, 22, 8, 5, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "UserFollows",
                columns: new[] { "Id", "CreatedAt", "FollowerId", "FollowingId", "IsFriend" },
                values: new object[,]
                {
                    { 1, new DateTime(2024, 5, 2, 12, 0, 0, 0, DateTimeKind.Unspecified), 2, 3, true },
                    { 2, new DateTime(2024, 5, 2, 18, 30, 0, 0, DateTimeKind.Unspecified), 3, 2, true },
                    { 3, new DateTime(2024, 9, 14, 9, 15, 0, 0, DateTimeKind.Unspecified), 2, 5, false },
                    { 4, new DateTime(2024, 9, 20, 20, 45, 0, 0, DateTimeKind.Unspecified), 4, 5, false },
                    { 5, new DateTime(2024, 9, 21, 7, 10, 0, 0, DateTimeKind.Unspecified), 5, 4, true },
                    { 6, new DateTime(2025, 2, 3, 16, 5, 0, 0, DateTimeKind.Unspecified), 4, 7, true },
                    { 7, new DateTime(2025, 2, 3, 16, 40, 0, 0, DateTimeKind.Unspecified), 7, 4, true },
                    { 8, new DateTime(2025, 6, 11, 11, 25, 0, 0, DateTimeKind.Unspecified), 6, 9, false },
                    { 9, new DateTime(2025, 7, 8, 13, 55, 0, 0, DateTimeKind.Unspecified), 8, 5, false },
                    { 10, new DateTime(2025, 8, 1, 19, 0, 0, 0, DateTimeKind.Unspecified), 9, 6, false },
                    { 11, new DateTime(2025, 11, 22, 10, 30, 0, 0, DateTimeKind.Unspecified), 3, 8, false },
                    { 12, new DateTime(2026, 1, 9, 21, 15, 0, 0, DateTimeKind.Unspecified), 7, 2, false }
                });

            migrationBuilder.InsertData(
                table: "UserReports",
                columns: new[] { "Id", "AdminComment", "CreatedAt", "Reason", "ReportedUserId", "ReporterId", "ResolvedAt", "ReviewedByUserId", "Status" },
                values: new object[,]
                {
                    { 1, "Confirmed across three reviews. Account deactivated pending acknowledgement of the content guidelines.", new DateTime(2026, 2, 14, 9, 15, 0, 0, DateTimeKind.Unspecified), "Repeatedly posting unmarked plot spoilers in review comments after being asked to use the spoiler flag.", 10, 2, new DateTime(2026, 2, 16, 11, 40, 0, 0, DateTimeKind.Unspecified), 1, 1 },
                    { 2, "Duplicate review removed. Account already deactivated from the earlier report.", new DateTime(2026, 4, 22, 8, 0, 0, 0, DateTimeKind.Unspecified), "Copied the text of another member's review word for word and posted it under their own account.", 10, 9, new DateTime(2026, 4, 23, 15, 25, 0, 0, DateTimeKind.Unspecified), 1, 1 },
                    { 3, null, new DateTime(2026, 7, 6, 19, 45, 0, 0, DateTimeKind.Unspecified), "Hostile replies on a clash entry, including personal remarks unrelated to the films listed.", 6, 5, null, null, 0 },
                    { 4, "Reviewed the exchange. Disagreement about a list is not a guideline violation and the comment was civil.", new DateTime(2026, 4, 26, 12, 30, 0, 0, DateTimeKind.Unspecified), "Downvoted my clash entry and left a rude comment.", 3, 6, new DateTime(2026, 4, 27, 9, 10, 0, 0, DateTimeKind.Unspecified), 1, 2 }
                });

            migrationBuilder.InsertData(
                table: "Activities",
                columns: new[] { "Id", "ClashId", "CreatedAt", "MovieId", "MovieListId", "ReviewId", "TargetUserId", "Type", "UserId" },
                values: new object[,]
                {
                    { 4, null, new DateTime(2025, 11, 3, 21, 40, 0, 0, DateTimeKind.Unspecified), 1, null, 1, null, 2, 2 },
                    { 5, null, new DateTime(2025, 12, 18, 23, 5, 0, 0, DateTimeKind.Unspecified), 2, null, 2, null, 2, 3 },
                    { 7, null, new DateTime(2026, 1, 7, 19, 30, 0, 0, DateTimeKind.Unspecified), 3, null, 3, null, 2, 5 },
                    { 9, null, new DateTime(2026, 2, 20, 20, 15, 0, 0, DateTimeKind.Unspecified), 5, null, 5, null, 2, 6 },
                    { 10, null, new DateTime(2026, 3, 14, 11, 45, 0, 0, DateTimeKind.Unspecified), 8, 1, null, null, 4, 2 },
                    { 11, null, new DateTime(2026, 4, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), null, 5, null, null, 5, 3 },
                    { 12, 1, new DateTime(2026, 4, 5, 16, 25, 0, 0, DateTimeKind.Unspecified), null, 5, null, null, 8, 3 },
                    { 13, 1, new DateTime(2026, 4, 6, 9, 55, 0, 0, DateTimeKind.Unspecified), null, 6, null, null, 8, 8 },
                    { 14, 1, new DateTime(2026, 5, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), null, 6, null, null, 9, 8 },
                    { 15, null, new DateTime(2026, 4, 9, 21, 10, 0, 0, DateTimeKind.Unspecified), 8, null, 8, null, 2, 4 },
                    { 17, null, new DateTime(2026, 6, 20, 8, 40, 0, 0, DateTimeKind.Unspecified), null, 7, null, null, 5, 5 },
                    { 18, 2, new DateTime(2026, 6, 22, 19, 15, 0, 0, DateTimeKind.Unspecified), null, 7, null, null, 8, 5 },
                    { 19, 2, new DateTime(2026, 6, 23, 12, 10, 0, 0, DateTimeKind.Unspecified), null, 8, null, null, 8, 9 }
                });

            migrationBuilder.InsertData(
                table: "ClashEntries",
                columns: new[] { "Id", "ClashId", "CreatedAt", "IsWinner", "MovieListId", "UserId" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2026, 4, 5, 16, 25, 0, 0, DateTimeKind.Unspecified), false, 5, 3 },
                    { 2, 1, new DateTime(2026, 4, 6, 9, 55, 0, 0, DateTimeKind.Unspecified), true, 6, 8 },
                    { 3, 2, new DateTime(2026, 6, 22, 19, 15, 0, 0, DateTimeKind.Unspecified), false, 7, 5 },
                    { 4, 2, new DateTime(2026, 6, 23, 12, 10, 0, 0, DateTimeKind.Unspecified), false, 8, 9 }
                });

            migrationBuilder.InsertData(
                table: "MovieListItems",
                columns: new[] { "Id", "AddedAt", "MovieId", "MovieListId", "Position" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 10, 4, 9, 0, 0, 0, DateTimeKind.Unspecified), 12, 1, 1 },
                    { 2, new DateTime(2025, 12, 1, 21, 30, 0, 0, DateTimeKind.Unspecified), 11, 1, 2 },
                    { 3, new DateTime(2026, 3, 14, 11, 45, 0, 0, DateTimeKind.Unspecified), 8, 1, 3 },
                    { 4, new DateTime(2025, 11, 9, 7, 20, 0, 0, DateTimeKind.Unspecified), 8, 2, 1 },
                    { 5, new DateTime(2026, 2, 17, 22, 10, 0, 0, DateTimeKind.Unspecified), 7, 2, 2 },
                    { 6, new DateTime(2025, 4, 12, 15, 5, 0, 0, DateTimeKind.Unspecified), 8, 3, 1 },
                    { 7, new DateTime(2025, 8, 30, 18, 40, 0, 0, DateTimeKind.Unspecified), 9, 3, 2 },
                    { 8, new DateTime(2025, 6, 18, 20, 15, 0, 0, DateTimeKind.Unspecified), 7, 4, 1 },
                    { 9, new DateTime(2025, 9, 7, 13, 25, 0, 0, DateTimeKind.Unspecified), 3, 4, 2 },
                    { 10, new DateTime(2026, 1, 26, 16, 0, 0, 0, DateTimeKind.Unspecified), 8, 4, 3 },
                    { 11, new DateTime(2026, 4, 2, 10, 5, 0, 0, DateTimeKind.Unspecified), 1, 5, 1 },
                    { 12, new DateTime(2026, 4, 2, 10, 8, 0, 0, DateTimeKind.Unspecified), 2, 5, 2 },
                    { 13, new DateTime(2026, 4, 2, 10, 12, 0, 0, DateTimeKind.Unspecified), 6, 5, 3 },
                    { 14, new DateTime(2026, 4, 3, 13, 30, 0, 0, DateTimeKind.Unspecified), 4, 6, 1 },
                    { 15, new DateTime(2026, 4, 3, 13, 34, 0, 0, DateTimeKind.Unspecified), 1, 6, 2 },
                    { 16, new DateTime(2026, 4, 3, 13, 38, 0, 0, DateTimeKind.Unspecified), 9, 6, 3 },
                    { 17, new DateTime(2026, 6, 20, 8, 45, 0, 0, DateTimeKind.Unspecified), 12, 7, 1 },
                    { 18, new DateTime(2026, 6, 20, 8, 49, 0, 0, DateTimeKind.Unspecified), 11, 7, 2 },
                    { 19, new DateTime(2026, 6, 20, 8, 52, 0, 0, DateTimeKind.Unspecified), 10, 7, 3 },
                    { 20, new DateTime(2026, 6, 21, 18, 0, 0, 0, DateTimeKind.Unspecified), 10, 8, 1 },
                    { 21, new DateTime(2026, 6, 21, 18, 4, 0, 0, DateTimeKind.Unspecified), 6, 8, 2 },
                    { 22, new DateTime(2026, 6, 21, 18, 7, 0, 0, DateTimeKind.Unspecified), 5, 8, 3 }
                });

            migrationBuilder.InsertData(
                table: "ClashVotes",
                columns: new[] { "Id", "ClashEntryId", "CreatedAt", "VoterId" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2026, 4, 20, 10, 5, 0, 0, DateTimeKind.Unspecified), 2 },
                    { 2, 1, new DateTime(2026, 4, 21, 18, 30, 0, 0, DateTimeKind.Unspecified), 4 },
                    { 3, 2, new DateTime(2026, 4, 20, 21, 40, 0, 0, DateTimeKind.Unspecified), 5 },
                    { 4, 2, new DateTime(2026, 4, 22, 8, 15, 0, 0, DateTimeKind.Unspecified), 6 },
                    { 5, 2, new DateTime(2026, 4, 25, 13, 0, 0, 0, DateTimeKind.Unspecified), 7 },
                    { 6, 3, new DateTime(2026, 7, 2, 20, 25, 0, 0, DateTimeKind.Unspecified), 4 },
                    { 7, 3, new DateTime(2026, 7, 8, 11, 50, 0, 0, DateTimeKind.Unspecified), 8 },
                    { 8, 4, new DateTime(2026, 7, 4, 17, 35, 0, 0, DateTimeKind.Unspecified), 6 },
                    { 9, 4, new DateTime(2026, 7, 12, 9, 5, 0, 0, DateTimeKind.Unspecified), 2 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Activities",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "ClashVotes",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "ClashVotes",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "ClashVotes",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "ClashVotes",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "ClashVotes",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "ClashVotes",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "ClashVotes",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "ClashVotes",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "ClashVotes",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Clashes",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Languages",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Languages",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 29);

            migrationBuilder.DeleteData(
                table: "MovieCasts",
                keyColumn: "Id",
                keyValue: 30);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 29);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 30);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 31);

            migrationBuilder.DeleteData(
                table: "MovieGenres",
                keyColumn: "Id",
                keyValue: 32);

            migrationBuilder.DeleteData(
                table: "MovieIssueReports",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "MovieIssueReports",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "MovieIssueReports",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "MovieIssueReports",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "MovieListItems",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "MovieRequests",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "MovieRequests",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "MovieRequests",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "MovieRequests",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "MovieStudio",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Studio",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "UserBlocks",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "UserBlocks",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "UserBlocks",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "UserFollows",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "CastMembers",
                keyColumn: "Id",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "ClashEntries",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "ClashEntries",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "ClashEntries",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "ClashEntries",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Genres",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "MovieLists",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "MovieLists",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "MovieLists",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "MovieLists",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Studio",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Studio",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Studio",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Studio",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Studio",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Studio",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Studio",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Studio",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Studio",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Clashes",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Clashes",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Languages",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Languages",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Languages",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "MovieLists",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "MovieLists",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "MovieLists",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "MovieLists",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Languages",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Languages",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Languages",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 9);
        }
    }
}
