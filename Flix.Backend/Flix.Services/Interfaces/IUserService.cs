using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IUserService
        : IBaseCRUDService<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        Task<UserSensitiveResponse?> GetByUsernameAsync(string username);
        Task UpdateLastLoginAsync(int userId);
        Task<List<UserResponse>> GetMostActiveUsersAsync();
    }
}
