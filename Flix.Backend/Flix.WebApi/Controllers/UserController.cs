using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class UserController
        : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest, IUserService>
    {

        public UserController(IUserService userService) : base(userService)
        {
        }

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Consumes("multipart/form-data")]
        [Authorization("Admin")]
        public override async Task<ActionResult<UserResponse>> Create([FromForm] UserInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return result;
        }

        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Consumes("multipart/form-data")]
        public override async Task<ActionResult<UserResponse>> Update(int id, [FromForm] UserUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);
            return result;
        }

        [Authorization("Admin")]
        [ProducesResponseType(typeof(PageResult<UserAdminResponse>), StatusCodes.Status200OK)]
        public override async Task<ActionResult<PageResult<UserResponse>>> Get([FromQuery] UserSearchObject? search)
        {
            return Ok(await _service.GetAdminAsync(search));
        }

        [Authorization("Admin")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}