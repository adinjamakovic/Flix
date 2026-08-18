using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flix.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class CascadeDeleteBehaviours : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Clashes_ClashId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_Activities_MovieLists_MovieListId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Movies_MovieId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Reviews_ReviewId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Users_TargetUserId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Users_UserId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_ClashEntries_Clashes_ClashId",
                table: "ClashEntries");

            migrationBuilder.DropForeignKey(
                name: "FK_ClashEntries_MovieLists_MovieListId",
                table: "ClashEntries");

            migrationBuilder.DropForeignKey(
                name: "FK_ClashEntries_Users_UserId",
                table: "ClashEntries");

            migrationBuilder.DropForeignKey(
                name: "FK_ClashVotes_ClashEntries_ClashEntryId",
                table: "ClashVotes");

            migrationBuilder.DropForeignKey(
                name: "FK_ClashVotes_Users_VoterId",
                table: "ClashVotes");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieCasts_CastMembers_CastMemberId",
                table: "MovieCasts");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieCasts_Movies_MovieId",
                table: "MovieCasts");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieGenres_Genres_GenreId",
                table: "MovieGenres");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieGenres_Movies_MovieId",
                table: "MovieGenres");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieIssueReports_Movies_MovieId",
                table: "MovieIssueReports");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieIssueReports_Users_ReportedByUserId",
                table: "MovieIssueReports");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieIssueReports_Users_ReviewedByUserId",
                table: "MovieIssueReports");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieListItems_MovieLists_MovieListId",
                table: "MovieListItems");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieListItems_Movies_MovieId",
                table: "MovieListItems");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieLists_Users_UserId",
                table: "MovieLists");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieRecommendations_Movies_MovieId",
                table: "MovieRecommendations");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieRecommendations_Movies_RecommendedMovieId",
                table: "MovieRecommendations");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieRequests_Movies_CreatedMovieId",
                table: "MovieRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieRequests_Users_RequestedByUserId",
                table: "MovieRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieRequests_Users_ReviewedByUserId",
                table: "MovieRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieStudio_Movies_MovieId",
                table: "MovieStudio");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieStudio_Studio_StudioId",
                table: "MovieStudio");

            migrationBuilder.DropForeignKey(
                name: "FK_RefreshTokens_Users_UserId",
                table: "RefreshTokens");

            migrationBuilder.DropForeignKey(
                name: "FK_Reviews_Movies_MovieId",
                table: "Reviews");

            migrationBuilder.DropForeignKey(
                name: "FK_Reviews_Users_UserId",
                table: "Reviews");

            migrationBuilder.DropForeignKey(
                name: "FK_UserBlocks_Users_BlockedId",
                table: "UserBlocks");

            migrationBuilder.DropForeignKey(
                name: "FK_UserBlocks_Users_BlockerId",
                table: "UserBlocks");

            migrationBuilder.DropForeignKey(
                name: "FK_UserFollows_Users_FollowerId",
                table: "UserFollows");

            migrationBuilder.DropForeignKey(
                name: "FK_UserFollows_Users_FollowingId",
                table: "UserFollows");

            migrationBuilder.DropForeignKey(
                name: "FK_UserReports_Users_ReportedUserId",
                table: "UserReports");

            migrationBuilder.DropForeignKey(
                name: "FK_UserReports_Users_ReporterId",
                table: "UserReports");

            migrationBuilder.DropForeignKey(
                name: "FK_UserReports_Users_ReviewedByUserId",
                table: "UserReports");

            migrationBuilder.DropForeignKey(
                name: "FK_UserRoles_Users_UserId",
                table: "UserRoles");

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Clashes_ClashId",
                table: "Activities",
                column: "ClashId",
                principalTable: "Clashes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_MovieLists_MovieListId",
                table: "Activities",
                column: "MovieListId",
                principalTable: "MovieLists",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Movies_MovieId",
                table: "Activities",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Reviews_ReviewId",
                table: "Activities",
                column: "ReviewId",
                principalTable: "Reviews",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Users_TargetUserId",
                table: "Activities",
                column: "TargetUserId",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Users_UserId",
                table: "Activities",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ClashEntries_Clashes_ClashId",
                table: "ClashEntries",
                column: "ClashId",
                principalTable: "Clashes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ClashEntries_MovieLists_MovieListId",
                table: "ClashEntries",
                column: "MovieListId",
                principalTable: "MovieLists",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ClashEntries_Users_UserId",
                table: "ClashEntries",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_ClashVotes_ClashEntries_ClashEntryId",
                table: "ClashVotes",
                column: "ClashEntryId",
                principalTable: "ClashEntries",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ClashVotes_Users_VoterId",
                table: "ClashVotes",
                column: "VoterId",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_MovieCasts_CastMembers_CastMemberId",
                table: "MovieCasts",
                column: "CastMemberId",
                principalTable: "CastMembers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieCasts_Movies_MovieId",
                table: "MovieCasts",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieGenres_Genres_GenreId",
                table: "MovieGenres",
                column: "GenreId",
                principalTable: "Genres",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieGenres_Movies_MovieId",
                table: "MovieGenres",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieIssueReports_Movies_MovieId",
                table: "MovieIssueReports",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieIssueReports_Users_ReportedByUserId",
                table: "MovieIssueReports",
                column: "ReportedByUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieIssueReports_Users_ReviewedByUserId",
                table: "MovieIssueReports",
                column: "ReviewedByUserId",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_MovieListItems_MovieLists_MovieListId",
                table: "MovieListItems",
                column: "MovieListId",
                principalTable: "MovieLists",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieListItems_Movies_MovieId",
                table: "MovieListItems",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieLists_Users_UserId",
                table: "MovieLists",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieRecommendations_Movies_MovieId",
                table: "MovieRecommendations",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_MovieRecommendations_Movies_RecommendedMovieId",
                table: "MovieRecommendations",
                column: "RecommendedMovieId",
                principalTable: "Movies",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_MovieRequests_Movies_CreatedMovieId",
                table: "MovieRequests",
                column: "CreatedMovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieRequests_Users_RequestedByUserId",
                table: "MovieRequests",
                column: "RequestedByUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieRequests_Users_ReviewedByUserId",
                table: "MovieRequests",
                column: "ReviewedByUserId",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_MovieStudio_Movies_MovieId",
                table: "MovieStudio",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieStudio_Studio_StudioId",
                table: "MovieStudio",
                column: "StudioId",
                principalTable: "Studio",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_RefreshTokens_Users_UserId",
                table: "RefreshTokens",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Reviews_Movies_MovieId",
                table: "Reviews",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Reviews_Users_UserId",
                table: "Reviews",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserBlocks_Users_BlockedId",
                table: "UserBlocks",
                column: "BlockedId",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_UserBlocks_Users_BlockerId",
                table: "UserBlocks",
                column: "BlockerId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserFollows_Users_FollowerId",
                table: "UserFollows",
                column: "FollowerId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserFollows_Users_FollowingId",
                table: "UserFollows",
                column: "FollowingId",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_UserReports_Users_ReportedUserId",
                table: "UserReports",
                column: "ReportedUserId",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_UserReports_Users_ReporterId",
                table: "UserReports",
                column: "ReporterId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserReports_Users_ReviewedByUserId",
                table: "UserReports",
                column: "ReviewedByUserId",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_UserRoles_Users_UserId",
                table: "UserRoles",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Clashes_ClashId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_Activities_MovieLists_MovieListId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Movies_MovieId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Reviews_ReviewId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Users_TargetUserId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_Activities_Users_UserId",
                table: "Activities");

            migrationBuilder.DropForeignKey(
                name: "FK_ClashEntries_Clashes_ClashId",
                table: "ClashEntries");

            migrationBuilder.DropForeignKey(
                name: "FK_ClashEntries_MovieLists_MovieListId",
                table: "ClashEntries");

            migrationBuilder.DropForeignKey(
                name: "FK_ClashEntries_Users_UserId",
                table: "ClashEntries");

            migrationBuilder.DropForeignKey(
                name: "FK_ClashVotes_ClashEntries_ClashEntryId",
                table: "ClashVotes");

            migrationBuilder.DropForeignKey(
                name: "FK_ClashVotes_Users_VoterId",
                table: "ClashVotes");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieCasts_CastMembers_CastMemberId",
                table: "MovieCasts");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieCasts_Movies_MovieId",
                table: "MovieCasts");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieGenres_Genres_GenreId",
                table: "MovieGenres");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieGenres_Movies_MovieId",
                table: "MovieGenres");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieIssueReports_Movies_MovieId",
                table: "MovieIssueReports");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieIssueReports_Users_ReportedByUserId",
                table: "MovieIssueReports");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieIssueReports_Users_ReviewedByUserId",
                table: "MovieIssueReports");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieListItems_MovieLists_MovieListId",
                table: "MovieListItems");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieListItems_Movies_MovieId",
                table: "MovieListItems");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieLists_Users_UserId",
                table: "MovieLists");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieRecommendations_Movies_MovieId",
                table: "MovieRecommendations");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieRecommendations_Movies_RecommendedMovieId",
                table: "MovieRecommendations");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieRequests_Movies_CreatedMovieId",
                table: "MovieRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieRequests_Users_RequestedByUserId",
                table: "MovieRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieRequests_Users_ReviewedByUserId",
                table: "MovieRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieStudio_Movies_MovieId",
                table: "MovieStudio");

            migrationBuilder.DropForeignKey(
                name: "FK_MovieStudio_Studio_StudioId",
                table: "MovieStudio");

            migrationBuilder.DropForeignKey(
                name: "FK_RefreshTokens_Users_UserId",
                table: "RefreshTokens");

            migrationBuilder.DropForeignKey(
                name: "FK_Reviews_Movies_MovieId",
                table: "Reviews");

            migrationBuilder.DropForeignKey(
                name: "FK_Reviews_Users_UserId",
                table: "Reviews");

            migrationBuilder.DropForeignKey(
                name: "FK_UserBlocks_Users_BlockedId",
                table: "UserBlocks");

            migrationBuilder.DropForeignKey(
                name: "FK_UserBlocks_Users_BlockerId",
                table: "UserBlocks");

            migrationBuilder.DropForeignKey(
                name: "FK_UserFollows_Users_FollowerId",
                table: "UserFollows");

            migrationBuilder.DropForeignKey(
                name: "FK_UserFollows_Users_FollowingId",
                table: "UserFollows");

            migrationBuilder.DropForeignKey(
                name: "FK_UserReports_Users_ReportedUserId",
                table: "UserReports");

            migrationBuilder.DropForeignKey(
                name: "FK_UserReports_Users_ReporterId",
                table: "UserReports");

            migrationBuilder.DropForeignKey(
                name: "FK_UserReports_Users_ReviewedByUserId",
                table: "UserReports");

            migrationBuilder.DropForeignKey(
                name: "FK_UserRoles_Users_UserId",
                table: "UserRoles");

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Clashes_ClashId",
                table: "Activities",
                column: "ClashId",
                principalTable: "Clashes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_MovieLists_MovieListId",
                table: "Activities",
                column: "MovieListId",
                principalTable: "MovieLists",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Movies_MovieId",
                table: "Activities",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Reviews_ReviewId",
                table: "Activities",
                column: "ReviewId",
                principalTable: "Reviews",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Users_TargetUserId",
                table: "Activities",
                column: "TargetUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Activities_Users_UserId",
                table: "Activities",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_ClashEntries_Clashes_ClashId",
                table: "ClashEntries",
                column: "ClashId",
                principalTable: "Clashes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_ClashEntries_MovieLists_MovieListId",
                table: "ClashEntries",
                column: "MovieListId",
                principalTable: "MovieLists",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_ClashEntries_Users_UserId",
                table: "ClashEntries",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_ClashVotes_ClashEntries_ClashEntryId",
                table: "ClashVotes",
                column: "ClashEntryId",
                principalTable: "ClashEntries",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_ClashVotes_Users_VoterId",
                table: "ClashVotes",
                column: "VoterId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieCasts_CastMembers_CastMemberId",
                table: "MovieCasts",
                column: "CastMemberId",
                principalTable: "CastMembers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieCasts_Movies_MovieId",
                table: "MovieCasts",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieGenres_Genres_GenreId",
                table: "MovieGenres",
                column: "GenreId",
                principalTable: "Genres",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieGenres_Movies_MovieId",
                table: "MovieGenres",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieIssueReports_Movies_MovieId",
                table: "MovieIssueReports",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieIssueReports_Users_ReportedByUserId",
                table: "MovieIssueReports",
                column: "ReportedByUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieIssueReports_Users_ReviewedByUserId",
                table: "MovieIssueReports",
                column: "ReviewedByUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieListItems_MovieLists_MovieListId",
                table: "MovieListItems",
                column: "MovieListId",
                principalTable: "MovieLists",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieListItems_Movies_MovieId",
                table: "MovieListItems",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieLists_Users_UserId",
                table: "MovieLists",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieRecommendations_Movies_MovieId",
                table: "MovieRecommendations",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieRecommendations_Movies_RecommendedMovieId",
                table: "MovieRecommendations",
                column: "RecommendedMovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieRequests_Movies_CreatedMovieId",
                table: "MovieRequests",
                column: "CreatedMovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieRequests_Users_RequestedByUserId",
                table: "MovieRequests",
                column: "RequestedByUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieRequests_Users_ReviewedByUserId",
                table: "MovieRequests",
                column: "ReviewedByUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieStudio_Movies_MovieId",
                table: "MovieStudio",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MovieStudio_Studio_StudioId",
                table: "MovieStudio",
                column: "StudioId",
                principalTable: "Studio",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_RefreshTokens_Users_UserId",
                table: "RefreshTokens",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Reviews_Movies_MovieId",
                table: "Reviews",
                column: "MovieId",
                principalTable: "Movies",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Reviews_Users_UserId",
                table: "Reviews",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_UserBlocks_Users_BlockedId",
                table: "UserBlocks",
                column: "BlockedId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_UserBlocks_Users_BlockerId",
                table: "UserBlocks",
                column: "BlockerId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_UserFollows_Users_FollowerId",
                table: "UserFollows",
                column: "FollowerId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_UserFollows_Users_FollowingId",
                table: "UserFollows",
                column: "FollowingId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_UserReports_Users_ReportedUserId",
                table: "UserReports",
                column: "ReportedUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_UserReports_Users_ReporterId",
                table: "UserReports",
                column: "ReporterId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_UserReports_Users_ReviewedByUserId",
                table: "UserReports",
                column: "ReviewedByUserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_UserRoles_Users_UserId",
                table: "UserRoles",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
