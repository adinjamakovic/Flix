using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flix.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class MovieRequestAdminComment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "AdminComment",
                table: "MovieRequests",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true);

            migrationBuilder.UpdateData(
                table: "MovieRequests",
                keyColumn: "Id",
                keyValue: 1,
                column: "AdminComment",
                value: null);

            migrationBuilder.UpdateData(
                table: "MovieRequests",
                keyColumn: "Id",
                keyValue: 2,
                column: "AdminComment",
                value: null);

            migrationBuilder.UpdateData(
                table: "MovieRequests",
                keyColumn: "Id",
                keyValue: 3,
                column: "AdminComment",
                value: null);

            migrationBuilder.UpdateData(
                table: "MovieRequests",
                keyColumn: "Id",
                keyValue: 4,
                column: "AdminComment",
                value: "The title you sent in is already in the catalogue under its original name, so there is nothing to add.");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AdminComment",
                table: "MovieRequests");
        }
    }
}
