using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flix.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Clashes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    BannerImageBase64 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Clashes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Countries",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Code = table.Column<string>(type: "nvarchar(5)", maxLength: 5, nullable: true),
                    FlagImageBase64 = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Countries", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Genres",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Genres", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Languages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(60)", maxLength: 60, nullable: false),
                    Code = table.Column<string>(type: "nvarchar(5)", maxLength: 5, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Languages", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Studio",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    LogoBase64 = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Studio", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CastMembers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    CountryId = table.Column<int>(type: "int", nullable: false),
                    BirthDate = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Biography = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhotoBase64 = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CastMembers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CastMembers_Countries_CountryId",
                        column: x => x.CountryId,
                        principalTable: "Countries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Username = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PasswordSalt = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsAdmin = table.Column<bool>(type: "bit", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    LastLoginAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(25)", maxLength: 25, nullable: true),
                    ProfileImageBase64 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Bio = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CountryId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Users_Countries_CountryId",
                        column: x => x.CountryId,
                        principalTable: "Countries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Movies",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PosterBase64 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    HeaderImageBase64 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TrailerUrl = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ReleaseDate = table.Column<DateTime>(type: "datetime2", nullable: true),
                    DurationMinutes = table.Column<int>(type: "int", nullable: true),
                    Views = table.Column<int>(type: "int", nullable: false),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false),
                    CountryId = table.Column<int>(type: "int", nullable: true),
                    LanguageId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Movies", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Movies_Countries_CountryId",
                        column: x => x.CountryId,
                        principalTable: "Countries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Movies_Languages_LanguageId",
                        column: x => x.LanguageId,
                        principalTable: "Languages",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MovieLists",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Type = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MovieLists", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MovieLists_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "UserBlocks",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BlockerId = table.Column<int>(type: "int", nullable: false),
                    BlockedId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserBlocks", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserBlocks_Users_BlockedId",
                        column: x => x.BlockedId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserBlocks_Users_BlockerId",
                        column: x => x.BlockerId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "UserFollows",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FollowerId = table.Column<int>(type: "int", nullable: false),
                    FollowingId = table.Column<int>(type: "int", nullable: false),
                    IsFriend = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserFollows", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserFollows_Users_FollowerId",
                        column: x => x.FollowerId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserFollows_Users_FollowingId",
                        column: x => x.FollowingId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "UserReports",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ReporterId = table.Column<int>(type: "int", nullable: false),
                    ReportedUserId = table.Column<int>(type: "int", nullable: false),
                    Reason = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ReviewedByUserId = table.Column<int>(type: "int", nullable: true),
                    ResolvedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    AdminComment = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserReports", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserReports_Users_ReportedUserId",
                        column: x => x.ReportedUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserReports_Users_ReporterId",
                        column: x => x.ReporterId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserReports_Users_ReviewedByUserId",
                        column: x => x.ReviewedByUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MovieCasts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MovieId = table.Column<int>(type: "int", nullable: false),
                    CastMemberId = table.Column<int>(type: "int", nullable: false),
                    Role = table.Column<int>(type: "int", nullable: false),
                    CharacterName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    OrderOfAppearence = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MovieCasts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MovieCasts_CastMembers_CastMemberId",
                        column: x => x.CastMemberId,
                        principalTable: "CastMembers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MovieCasts_Movies_MovieId",
                        column: x => x.MovieId,
                        principalTable: "Movies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MovieGenres",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MovieId = table.Column<int>(type: "int", nullable: false),
                    GenreId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MovieGenres", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MovieGenres_Genres_GenreId",
                        column: x => x.GenreId,
                        principalTable: "Genres",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MovieGenres_Movies_MovieId",
                        column: x => x.MovieId,
                        principalTable: "Movies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MovieIssueReports",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MovieId = table.Column<int>(type: "int", nullable: false),
                    ReportedByUserId = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ReviewedByUserId = table.Column<int>(type: "int", nullable: true),
                    ResolvedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    AdminComment = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MovieIssueReports", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MovieIssueReports_Movies_MovieId",
                        column: x => x.MovieId,
                        principalTable: "Movies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MovieIssueReports_Users_ReportedByUserId",
                        column: x => x.ReportedByUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MovieIssueReports_Users_ReviewedByUserId",
                        column: x => x.ReviewedByUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MovieRequests",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RequestedByUserId = table.Column<int>(type: "int", nullable: false),
                    CreatedMovieId = table.Column<int>(type: "int", nullable: true),
                    Status = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ReviewedByUserId = table.Column<int>(type: "int", nullable: true),
                    ReviewedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MovieRequests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MovieRequests_Movies_CreatedMovieId",
                        column: x => x.CreatedMovieId,
                        principalTable: "Movies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MovieRequests_Users_RequestedByUserId",
                        column: x => x.RequestedByUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MovieRequests_Users_ReviewedByUserId",
                        column: x => x.ReviewedByUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MovieStudio",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MovieId = table.Column<int>(type: "int", nullable: false),
                    StudioId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MovieStudio", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MovieStudio_Movies_MovieId",
                        column: x => x.MovieId,
                        principalTable: "Movies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MovieStudio_Studio_StudioId",
                        column: x => x.StudioId,
                        principalTable: "Studio",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    MovieId = table.Column<int>(type: "int", nullable: false),
                    Rating = table.Column<decimal>(type: "decimal(2,1)", nullable: true),
                    IsLiked = table.Column<bool>(type: "bit", nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ContainsSpoilers = table.Column<bool>(type: "bit", nullable: false),
                    IsDiaryEntry = table.Column<bool>(type: "bit", nullable: false),
                    IsRewatch = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reviews", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reviews_Movies_MovieId",
                        column: x => x.MovieId,
                        principalTable: "Movies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Reviews_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ClashEntries",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ClashId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    MovieListId = table.Column<int>(type: "int", nullable: false),
                    IsWinner = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClashEntries", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ClashEntries_Clashes_ClashId",
                        column: x => x.ClashId,
                        principalTable: "Clashes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ClashEntries_MovieLists_MovieListId",
                        column: x => x.MovieListId,
                        principalTable: "MovieLists",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ClashEntries_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MovieListItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MovieListId = table.Column<int>(type: "int", nullable: false),
                    MovieId = table.Column<int>(type: "int", nullable: false),
                    Position = table.Column<int>(type: "int", nullable: false),
                    AddedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MovieListItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MovieListItems_MovieLists_MovieListId",
                        column: x => x.MovieListId,
                        principalTable: "MovieLists",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MovieListItems_Movies_MovieId",
                        column: x => x.MovieId,
                        principalTable: "Movies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Activities",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Type = table.Column<int>(type: "int", nullable: false),
                    MovieId = table.Column<int>(type: "int", nullable: true),
                    ReviewId = table.Column<int>(type: "int", nullable: true),
                    ClashId = table.Column<int>(type: "int", nullable: true),
                    MovieListId = table.Column<int>(type: "int", nullable: true),
                    TargetUserId = table.Column<int>(type: "int", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Activities", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Activities_Clashes_ClashId",
                        column: x => x.ClashId,
                        principalTable: "Clashes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Activities_MovieLists_MovieListId",
                        column: x => x.MovieListId,
                        principalTable: "MovieLists",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Activities_Movies_MovieId",
                        column: x => x.MovieId,
                        principalTable: "Movies",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Activities_Reviews_ReviewId",
                        column: x => x.ReviewId,
                        principalTable: "Reviews",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Activities_Users_TargetUserId",
                        column: x => x.TargetUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Activities_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ClashVotes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ClashEntryId = table.Column<int>(type: "int", nullable: false),
                    VoterId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClashVotes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ClashVotes_ClashEntries_ClashEntryId",
                        column: x => x.ClashEntryId,
                        principalTable: "ClashEntries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ClashVotes_Users_VoterId",
                        column: x => x.VoterId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Activities_ClashId",
                table: "Activities",
                column: "ClashId");

            migrationBuilder.CreateIndex(
                name: "IX_Activities_MovieId",
                table: "Activities",
                column: "MovieId");

            migrationBuilder.CreateIndex(
                name: "IX_Activities_MovieListId",
                table: "Activities",
                column: "MovieListId");

            migrationBuilder.CreateIndex(
                name: "IX_Activities_ReviewId",
                table: "Activities",
                column: "ReviewId");

            migrationBuilder.CreateIndex(
                name: "IX_Activities_TargetUserId",
                table: "Activities",
                column: "TargetUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Activities_UserId",
                table: "Activities",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_CastMembers_CountryId",
                table: "CastMembers",
                column: "CountryId");

            migrationBuilder.CreateIndex(
                name: "IX_ClashEntries_ClashId",
                table: "ClashEntries",
                column: "ClashId");

            migrationBuilder.CreateIndex(
                name: "IX_ClashEntries_MovieListId",
                table: "ClashEntries",
                column: "MovieListId");

            migrationBuilder.CreateIndex(
                name: "IX_ClashEntries_UserId",
                table: "ClashEntries",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_ClashVotes_ClashEntryId",
                table: "ClashVotes",
                column: "ClashEntryId");

            migrationBuilder.CreateIndex(
                name: "IX_ClashVotes_VoterId_ClashEntryId",
                table: "ClashVotes",
                columns: new[] { "VoterId", "ClashEntryId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Genres_Name",
                table: "Genres",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MovieCasts_CastMemberId",
                table: "MovieCasts",
                column: "CastMemberId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieCasts_MovieId",
                table: "MovieCasts",
                column: "MovieId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieGenres_GenreId",
                table: "MovieGenres",
                column: "GenreId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieGenres_MovieId_GenreId",
                table: "MovieGenres",
                columns: new[] { "MovieId", "GenreId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MovieIssueReports_MovieId",
                table: "MovieIssueReports",
                column: "MovieId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieIssueReports_ReportedByUserId",
                table: "MovieIssueReports",
                column: "ReportedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieIssueReports_ReviewedByUserId",
                table: "MovieIssueReports",
                column: "ReviewedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieListItems_MovieId",
                table: "MovieListItems",
                column: "MovieId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieListItems_MovieListId_MovieId",
                table: "MovieListItems",
                columns: new[] { "MovieListId", "MovieId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MovieLists_UserId",
                table: "MovieLists",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieRequests_CreatedMovieId",
                table: "MovieRequests",
                column: "CreatedMovieId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieRequests_RequestedByUserId",
                table: "MovieRequests",
                column: "RequestedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieRequests_ReviewedByUserId",
                table: "MovieRequests",
                column: "ReviewedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Movies_CountryId",
                table: "Movies",
                column: "CountryId");

            migrationBuilder.CreateIndex(
                name: "IX_Movies_LanguageId",
                table: "Movies",
                column: "LanguageId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieStudio_MovieId",
                table: "MovieStudio",
                column: "MovieId");

            migrationBuilder.CreateIndex(
                name: "IX_MovieStudio_StudioId",
                table: "MovieStudio",
                column: "StudioId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_MovieId",
                table: "Reviews",
                column: "MovieId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId",
                table: "Reviews",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_UserBlocks_BlockedId",
                table: "UserBlocks",
                column: "BlockedId");

            migrationBuilder.CreateIndex(
                name: "IX_UserBlocks_BlockerId_BlockedId",
                table: "UserBlocks",
                columns: new[] { "BlockerId", "BlockedId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserFollows_FollowerId_FollowingId",
                table: "UserFollows",
                columns: new[] { "FollowerId", "FollowingId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserFollows_FollowingId",
                table: "UserFollows",
                column: "FollowingId");

            migrationBuilder.CreateIndex(
                name: "IX_UserReports_ReportedUserId",
                table: "UserReports",
                column: "ReportedUserId");

            migrationBuilder.CreateIndex(
                name: "IX_UserReports_ReporterId",
                table: "UserReports",
                column: "ReporterId");

            migrationBuilder.CreateIndex(
                name: "IX_UserReports_ReviewedByUserId",
                table: "UserReports",
                column: "ReviewedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_CountryId",
                table: "Users",
                column: "CountryId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_Username",
                table: "Users",
                column: "Username",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Activities");

            migrationBuilder.DropTable(
                name: "ClashVotes");

            migrationBuilder.DropTable(
                name: "MovieCasts");

            migrationBuilder.DropTable(
                name: "MovieGenres");

            migrationBuilder.DropTable(
                name: "MovieIssueReports");

            migrationBuilder.DropTable(
                name: "MovieListItems");

            migrationBuilder.DropTable(
                name: "MovieRequests");

            migrationBuilder.DropTable(
                name: "MovieStudio");

            migrationBuilder.DropTable(
                name: "UserBlocks");

            migrationBuilder.DropTable(
                name: "UserFollows");

            migrationBuilder.DropTable(
                name: "UserReports");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "ClashEntries");

            migrationBuilder.DropTable(
                name: "CastMembers");

            migrationBuilder.DropTable(
                name: "Genres");

            migrationBuilder.DropTable(
                name: "Studio");

            migrationBuilder.DropTable(
                name: "Movies");

            migrationBuilder.DropTable(
                name: "Clashes");

            migrationBuilder.DropTable(
                name: "MovieLists");

            migrationBuilder.DropTable(
                name: "Languages");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Countries");
        }
    }
}
