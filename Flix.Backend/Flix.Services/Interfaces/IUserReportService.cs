using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IUserReportService :
        IBaseReadService<UserReportResponse, UserReportSearchObject>
    {
    }
}
