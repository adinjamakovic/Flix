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
        private readonly IPasswordResetService _passwordResetService;

        public AccessController(
            IAccessManager accessManager,
            IUserService userService,
            IPasswordResetService passwordResetService)
        {
            _accessManager = accessManager;
            _userService = userService;
            _passwordResetService = passwordResetService;
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

        [AllowAnonymous]
        [HttpPost("ForgotPassword")]
        public async Task<ActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            await _passwordResetService.RequestResetAsync(request);
            return Ok("If that email belongs to an account, a reset code is on its way.");
        }

        [AllowAnonymous]
        [HttpPost("VerifyResetToken")]
        public async Task<ActionResult> VerifyResetToken([FromBody] VerifyResetTokenRequest request)
        {
            await _passwordResetService.VerifyTokenAsync(request);
            return Ok("The reset code is valid.");
        }

        [AllowAnonymous]
        [HttpPost("ResetPassword")]
        public async Task<ActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            await _passwordResetService.ResetPasswordAsync(request);
            return Ok("Your password has been changed. Sign in with the new one.");
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
