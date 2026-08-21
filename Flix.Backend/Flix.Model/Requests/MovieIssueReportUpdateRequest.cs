using Flix.Model.Enums;

namespace Flix.Model.Requests
{
    // Updating a Movie Issue Report can be one of two scenarios:
    //          1. The user modifies their initial movie report 
    //      (i.e. descritpion contains false information so they need to correct it)
    //          2. The admin reviews the movie report 
    //      (thus the Status, and AdminComment fields)
    public class MovieIssueReportUpdateRequest
    {
        public int MovieId {get; set;}
        public string Header {get; set;} = string.Empty;
        public string? Description {get; set;}
        public ReportStatus? Status {get; set;}
        public string? AdminComment {get; set;}
    }
}