using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;

namespace Flix.WebApi.Controllers
{
    public class UserReportController
        : BaseReadController<UserReportResponse, UserReportSearchObject, IUserReportService>
    {
        public UserReportController(IUserReportService service) : base(service)
        {
        }
    }
}
