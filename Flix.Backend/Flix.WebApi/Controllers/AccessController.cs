using Flix.Model.Access;
using Flix.Model.Requests;
using Flix.Services.Interfaces;
using Flix.WebApi.Services.AccessManager;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AccessController : ControllerBase
    {
        private readonly IAccessManager _accessManager;
        private readonly IUserService _userService;

        public AccessController(IAccessManager accessManager, IUserService userService)
        {
            _accessManager = accessManager;
            _userService = userService;
        }

        [AllowAnonymous]
        [HttpPost("Login")]
        public async Task<ActionResult> Login([FromBody] UserLoginRequest request)
        {
            var result = await _accessManager.LoginAsync(request);
            return Ok(result);
        }

        [HttpPost("LoginWithRefreshToken")]
        public async Task<ActionResult> LoginWithRefreshToken([FromBody] RefreshAccessTokenRequest request)
        {
            var result = await _accessManager.LoginWithRefreshTokenAsync(request);
            return Ok(result);
        }
        [Authorize]
        [HttpPost("Logout")]
        public async Task<ActionResult> Logout()
        {
            await _accessManager.LogoutAsync();
            return Ok();
        }

        // UserInsertRequest carries the profile image as an IFormFile, so registration is
        // multipart rather than JSON.
        [AllowAnonymous]
        [HttpPost("Register")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> Register([FromForm] UserInsertRequest request)
        {
            request.RoleId = null;

            await _userService.InsertAsync(request);
            return Ok("You have succesfully registered your user account on Flix");
        }
    }
}
