using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flix.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class MoviePosters : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/the_godfather_header.png", "Movie/the_godfather_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/pulp_fiction_header.png", "Movie/pulp_fiction_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/spirited_away_header.png", "Movie/spirited_away_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/parasite_header.png", "Movie/parasite_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/inception_header.png", "Movie/inception_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/the_dark_knight_header.png", "Movie/the_dark_knight_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/amelie_header.png", "Movie/amelie_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/cinema_paradiso_header.png", "Movie/cinema_paradiso_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/everything_everywhere_all_at_once_header.png", "Movie/everything_everywhere_all_at_once_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/mad_max_fury_road_header.png", "Movie/mad_max_fury_road_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/das_boot_header.png", "Movie/das_boot_poster.png" });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 12,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { "Movie/seven_samurai_header.png", "Movie/seven_samurai_poster.png" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Movies",
                keyColumn: "Id",
                keyValue: 12,
                columns: new[] { "HeaderImage", "Poster" },
                values: new object[] { null, null });
        }
    }
}
