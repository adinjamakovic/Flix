using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    [ApiController]
    [Authorize]
    [Route("[controller]")]
    public class UserNetworkController : ControllerBase
    {
        private readonly IUserNetworkService _service;

        public UserNetworkController(IUserNetworkService service)
        {
            _service = service;
        }

        [HttpGet("Followers/{userId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<PageResult<UserResponse>>> GetFollowers(int userId, [FromQuery] BaseSearchObject? search)
        {
            return Ok(await _service.GetFollowersAsync(userId, search));
        }

        [HttpGet("Following/{userId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<PageResult<UserResponse>>> GetFollowing(int userId, [FromQuery] BaseSearchObject? search)
        {
            return Ok(await _service.GetFollowingAsync(userId, search));
        }

        [HttpGet("Blocked")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<PageResult<UserResponse>>> GetBlocked([FromQuery] BaseSearchObject? search)
        {
            return Ok(await _service.GetBlockedAsync(search));
        }

        [HttpGet("Relationship/{userId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<UserRelationshipResponse>> GetRelationship(int userId)
        {
            return Ok(await _service.GetRelationshipAsync(userId));
        }

        [HttpPost("Follow/{userId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<UserRelationshipResponse>> Follow(int userId)
        {
            return Ok(await _service.FollowAsync(userId));
        }

        [HttpDelete("Follow/{userId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<UserRelationshipResponse>> Unfollow(int userId)
        {
            return Ok(await _service.UnfollowAsync(userId));
        }

        [HttpPost("Block/{userId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<UserRelationshipResponse>> Block(int userId)
        {
            return Ok(await _service.BlockAsync(userId));
        }

        [HttpDelete("Block/{userId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<UserRelationshipResponse>> Unblock(int userId)
        {
            return Ok(await _service.UnblockAsync(userId));
        }

        [HttpPost("Report")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Report(UserReportInsertRequest request)
        {
            await _service.ReportAsync(request);
            return NoContent();
        }
    }
}
