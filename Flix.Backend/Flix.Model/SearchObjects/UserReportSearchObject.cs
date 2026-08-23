using Flix.Model.Enums;

namespace Flix.Model.SearchObjects
{
    public class UserReportSearchObject : BaseSearchObject
    {
        // Listing is done in two scenarios:
        //          1. Admin reviewing user submissions
        //          2. User seeing his sent reports
        public int? ReporterId {get; set;}
        public int? ReportedUserId {get; set;}
        public ReportStatus? Status {get; set;}
        public bool? IncludeReporter {get; set;}
        public bool? IncludeReportedUser {get; set;}
        public bool? IncludeReviewedBy {get; set;}
    }
}
