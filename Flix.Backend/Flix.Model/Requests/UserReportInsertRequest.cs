namespace Flix.Model.Requests
{
    // Reporting is only done by the currently logged in user, and every report starts
    // out as ReportStatus.Open, so neither is sent through the request.
    public class UserReportInsertRequest
    {
        public int ReportedUserId { get; set; }
        public string Header { get; set; } = string.Empty;
        public string? Description { get; set; }
    }
}
