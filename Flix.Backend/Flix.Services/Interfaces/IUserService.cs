using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IUserService
        : IBaseCRUDService<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        Task<PageResult<UserAdminResponse>> GetAdminAsync(UserSearchObject? search = null);
        Task<UserSensitiveResponse?> GetByUsernameAsync(string username);
        Task<UserAdminResponse?> GetAccountByIdAsync(int id);
        Task UpdateLastLoginAsync(int userId);
        Task<List<UserResponse>> GetMostActiveUsersAsync();
    }
}
