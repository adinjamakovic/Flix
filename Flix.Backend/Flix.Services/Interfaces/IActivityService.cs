using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    // Activities are written by the services that cause them, never by a client, so there is no
    // update and no delete here - an activity is a record of something that already happened.
    public interface IActivityService
        : IBaseReadService<ActivityResponse, ActivitySearchObject>
    {
        Task<ActivityResponse> InsertAsync(ActivityInsertRequest request);
        Task<ActivityResponse> InsertAsync(int userId, ActivityInsertRequest request);
        Task<PageResult<ActivityResponse>> GetFromFollowersAsync(ActivitySearchObject? search = null);
        Task<PageResult<ActivityResponse>> GetFromSelfAsync(ActivitySearchObject? search = null);
    }
}
