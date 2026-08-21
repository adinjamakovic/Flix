using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IMovieIssueReportService : 
        IBaseCRUDService<
            MovieIssueReportResponse, 
            MovieIssueReportSearchObject, 
            MovieIssueReportInsertRequest, 
            MovieIssueReportUpdateRequest>
    {
    }
}