using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet]
        public async Task<ActionResult<PageResult<UserResponse>>> Get([FromQuery] UserSearchObject? search)
        {
            return Ok(await _userService.GetAsync(search));
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UserResponse>> GetById(int id)
        {
            try
            {
                return Ok(await _userService.GetByIdAsync(id));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<UserResponse>> Insert([FromBody] UserInsertRequest request)
        {
            try
            {
                var user = await _userService.InsertAsync(request);
                return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { errors = ex.Errors.Select(e => e.ErrorMessage) });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<UserResponse>> Update(int id, [FromBody] UserUpdateRequest request)
        {
            try
            {
                return Ok(await _userService.UpdateAsync(id, request));
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { errors = ex.Errors.Select(e => e.ErrorMessage) });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                await _userService.DeleteAsync(id);
                return NoContent();
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
        }
    }
}