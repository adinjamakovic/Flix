using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    // Read-only: roles are seeded and assigned to users, not authored through the API.
    public interface IRoleService : IBaseReadService<RoleResponse, RoleSearchObject>
    {
    }
}
