namespace Flix.Model.Requests
{
    // Inserting is only done by the currently logged in user.
    // Which means there is no need to send a user id through the request.
    // All created Issues are at first assigned to ReportStatus.Open
    // so there is no need to send the status either
    public class MovieIssueReportInsertRequest
    {
        public int MovieId {get; set;}
        public string Header {get; set;} = string.Empty;
        public string? Description {get; set;}
        
    }
}