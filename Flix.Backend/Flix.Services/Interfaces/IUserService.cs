using Flix.Model.Access;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;

namespace Flix.Services.Interfaces
{
    public interface IUserService
        : IBaseCRUDService<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        Task<UserSensitiveResponse> GetByUsernameAsync(string username);
    }
}
