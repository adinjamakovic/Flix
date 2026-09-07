using Flix.Model.Enums;

namespace Flix.Services.Implementations
{
    internal static class ReportNotificationText
    {
        public static string Title(ReportStatus status) => $"Report {status.ToString().ToLowerInvariant()}";

        public static string Message(string header, ReportStatus status, string? adminComment)
        {
            var outcome = status == ReportStatus.Resolved ? "was resolved" : "was dismissed";

            var comment = string.IsNullOrWhiteSpace(adminComment)
                ? string.Empty
                : $" Admin reply: {adminComment.Trim()}";

            return $"Your report \"{header}\" {outcome}.{comment}";
        }
    }
}
