using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flix.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class movieIssueReportsCorrection : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Description",
                table: "MovieIssueReports",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(2000)",
                oldMaxLength: 2000);

            migrationBuilder.AddColumn<string>(
                name: "Header",
                table: "MovieIssueReports",
                type: "nvarchar(150)",
                maxLength: 150,
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "MovieIssueReports",
                keyColumn: "Id",
                keyValue: 1,
                column: "Header",
                value: "Runtime does not match the theatrical cut");

            migrationBuilder.UpdateData(
                table: "MovieIssueReports",
                keyColumn: "Id",
                keyValue: 2,
                column: "Header",
                value: "Listed duration matches no known version");

            migrationBuilder.UpdateData(
                table: "MovieIssueReports",
                keyColumn: "Id",
                keyValue: 3,
                column: "Header",
                value: "Trailer links to the English dub");

            migrationBuilder.UpdateData(
                table: "MovieIssueReports",
                keyColumn: "Id",
                keyValue: 4,
                column: "Header",
                value: "Synopsis contains a spoiler");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Header",
                table: "MovieIssueReports");

            migrationBuilder.AlterColumn<string>(
                name: "Description",
                table: "MovieIssueReports",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(2000)",
                oldMaxLength: 2000,
                oldNullable: true);
        }
    }
}
