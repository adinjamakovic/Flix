using Flix.Model.Enums;

namespace Flix.Model.Responses
{
    public class MovieIssueReportResponse
    {
        public int Id {get; set;}
        public int MovieId {get; set;}
        public string Header {get; set;} = string.Empty;
        public string? Description {get; set;}
        public ReportStatus Status {get; set;}
        public DateTime CreatedAt {get; set;}
        public UserResponse? ReportedBy {get; set;}
        public MovieResponse? Movie {get; set;}
        public UserResponse? ReviewedBy {get; set;}
        public DateTime? ResolvedAt {get; set;}
        public string? AdminComment {get; set;}
    }
}