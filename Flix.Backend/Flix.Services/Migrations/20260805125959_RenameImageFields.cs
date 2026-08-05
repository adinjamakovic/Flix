using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flix.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class RenameImageFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "ProfileImageBase64",
                table: "Users",
                newName: "ProfileImage");

            migrationBuilder.RenameColumn(
                name: "LogoBase64",
                table: "Studio",
                newName: "Logo");

            migrationBuilder.RenameColumn(
                name: "PosterBase64",
                table: "Movies",
                newName: "Poster");

            migrationBuilder.RenameColumn(
                name: "HeaderImageBase64",
                table: "Movies",
                newName: "HeaderImage");

            migrationBuilder.RenameColumn(
                name: "FlagImageBase64",
                table: "Countries",
                newName: "FlagImage");

            migrationBuilder.RenameColumn(
                name: "BannerImageBase64",
                table: "Clashes",
                newName: "BannerImage");

            migrationBuilder.RenameColumn(
                name: "PhotoBase64",
                table: "CastMembers",
                newName: "Photo");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "ProfileImage",
                table: "Users",
                newName: "ProfileImageBase64");

            migrationBuilder.RenameColumn(
                name: "Logo",
                table: "Studio",
                newName: "LogoBase64");

            migrationBuilder.RenameColumn(
                name: "Poster",
                table: "Movies",
                newName: "PosterBase64");

            migrationBuilder.RenameColumn(
                name: "HeaderImage",
                table: "Movies",
                newName: "HeaderImageBase64");

            migrationBuilder.RenameColumn(
                name: "FlagImage",
                table: "Countries",
                newName: "FlagImageBase64");

            migrationBuilder.RenameColumn(
                name: "BannerImage",
                table: "Clashes",
                newName: "BannerImageBase64");

            migrationBuilder.RenameColumn(
                name: "Photo",
                table: "CastMembers",
                newName: "PhotoBase64");
        }
    }
}
