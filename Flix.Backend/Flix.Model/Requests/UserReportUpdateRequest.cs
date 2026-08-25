using Flix.Model.Enums;

namespace Flix.Model.Requests
{
    // A user report is written from the mobile client through UserNetwork/Report and
    // the reporter never edits it afterwards, so the only thing left to update is the
    // admin's review of it.
    public class UserReportUpdateRequest
    {
        public ReportStatus? Status { get; set; }
        public string? AdminComment { get; set; }
    }
}
