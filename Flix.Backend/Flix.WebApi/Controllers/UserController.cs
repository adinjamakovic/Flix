using Flix.Model.Access;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class UserController
        : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest, IUserService>
    {

        public UserController(IUserService userService) : base(userService)
        {
        }

        [Authorization("Admin")]
        public override Task<ActionResult<PageResult<UserResponse>>> Get([FromQuery] UserSearchObject? search)
        {
            return base.Get(search);
        }
    }
}