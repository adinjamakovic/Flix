using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flix.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class UserReportHeaderAndDescription : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "UserReports",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Header",
                table: "UserReports",
                type: "nvarchar(150)",
                maxLength: 150,
                nullable: false,
                defaultValue: "");

            // A report written before the split has one free text reason and no header, and the
            // reason is up to 1000 characters - far past what Header takes - so it becomes the
            // description and the header falls back to the catch-all the picker offers.
            migrationBuilder.Sql(
                "UPDATE UserReports SET Description = Reason, Header = 'Other' WHERE Reason <> ''");

            migrationBuilder.DropColumn(
                name: "Reason",
                table: "UserReports");

            migrationBuilder.UpdateData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Description", "Header" },
                values: new object[] { "Repeatedly posting unmarked plot spoilers in review comments after being asked to use the spoiler flag.", "Deliberate spoilers" });

            migrationBuilder.UpdateData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Description", "Header" },
                values: new object[] { "Copied the text of another member's review word for word and posted it under their own account.", "Inappropriate reviews or lists" });

            migrationBuilder.UpdateData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Description", "Header" },
                values: new object[] { "Hostile replies on a clash entry, including personal remarks unrelated to the films listed.", "Harassment or bullying" });

            migrationBuilder.UpdateData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "Description", "Header" },
                values: new object[] { "Downvoted my clash entry and left a rude comment.", "Harassment or bullying" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Reason",
                table: "UserReports",
                type: "nvarchar(1000)",
                maxLength: 1000,
                nullable: false,
                defaultValue: "");

            // Reason is the shorter of the two columns, so a long description is cut to fit.
            migrationBuilder.Sql(
                "UPDATE UserReports SET Reason = LEFT(COALESCE(Description, Header), 1000)");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "UserReports");

            migrationBuilder.DropColumn(
                name: "Header",
                table: "UserReports");

            migrationBuilder.UpdateData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 1,
                column: "Reason",
                value: "Repeatedly posting unmarked plot spoilers in review comments after being asked to use the spoiler flag.");

            migrationBuilder.UpdateData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 2,
                column: "Reason",
                value: "Copied the text of another member's review word for word and posted it under their own account.");

            migrationBuilder.UpdateData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 3,
                column: "Reason",
                value: "Hostile replies on a clash entry, including personal remarks unrelated to the films listed.");

            migrationBuilder.UpdateData(
                table: "UserReports",
                keyColumn: "Id",
                keyValue: 4,
                column: "Reason",
                value: "Downvoted my clash entry and left a rude comment.");
        }
    }
}
