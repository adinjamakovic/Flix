using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IUserNetworkService
    {
        Task<PageResult<UserResponse>> GetFollowersAsync(int userId, BaseSearchObject? search = null);
        Task<PageResult<UserResponse>> GetFollowingAsync(int userId, BaseSearchObject? search = null);
        Task<PageResult<UserResponse>> GetBlockedAsync(BaseSearchObject? search = null);
        Task<UserRelationshipResponse> GetRelationshipAsync(int userId);
        Task<UserRelationshipResponse> FollowAsync(int userId);
        Task<UserRelationshipResponse> UnfollowAsync(int userId);
        Task<UserRelationshipResponse> BlockAsync(int userId);
        Task<UserRelationshipResponse> UnblockAsync(int userId);
        Task ReportAsync(UserReportInsertRequest request);
    }
}
