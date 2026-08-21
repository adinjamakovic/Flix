using Flix.Model.Enums;

namespace Flix.Model.SearchObjects
{
    public class MovieIssueReportSearchObject : BaseSearchObject
    {
        // Filtered by the user who reported the issue. Listing is done in
        // two scenarios:
        //          1. Admin reviewing user submissions
        //          2. User seeing his sent reports
        public int? UserId {get; set;}
        public ReportStatus? Status {get; set;}
        public bool? IncludeReportedBy {get; set;}
        public bool? IncludeReviewedBy {get; set;}
        public bool? IncludeMovie {get; set;}
    }
}