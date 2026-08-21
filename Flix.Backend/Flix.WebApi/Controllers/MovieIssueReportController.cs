using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;

namespace Flix.WebApi.Controllers
{
    public class MovieIssueReportController
        : BaseCRUDController<MovieIssueReportResponse, MovieIssueReportSearchObject, MovieIssueReportInsertRequest, MovieIssueReportUpdateRequest, IMovieIssueReportService>
    {
        public MovieIssueReportController(IMovieIssueReportService service) : base(service)
        {
        }
    }
}