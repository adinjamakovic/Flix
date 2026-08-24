using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IUserReportService :
        IBaseReadService<UserReportResponse, UserReportSearchObject>
    {
        Task<UserReportResponse> ReviewAsync(int id, UserReportUpdateRequest request);
    }
}
