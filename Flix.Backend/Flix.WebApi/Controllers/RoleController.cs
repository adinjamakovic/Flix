using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class RoleController : BaseReadController<RoleResponse, RoleSearchObject, IRoleService>
    {
        public RoleController(IRoleService roleService) : base(roleService)
        {
        }

        // Only an admin assigns roles, so only an admin needs to enumerate them.
        [Authorization("Admin")]
        public override Task<ActionResult<PageResult<RoleResponse>>> Get([FromQuery] RoleSearchObject? search)
        {
            return base.Get(search);
        }
    }
}
