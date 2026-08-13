using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Implementations;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class ReviewController : BaseReadController<ReviewResponse, ReviewSearchObject, IReviewService>
    {
        private readonly ICurrentUserService _currentUserService;

        public ReviewController(IReviewService service, ICurrentUserService currentUserService) : base(service)
        {
            _currentUserService = currentUserService;
        }

        [HttpGet("LatestFromFriends")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<List<ReviewResponse>>> GetLatestFromFriends()
        {
            var result = await _service.GetLatestReviewsFromFriendsAsync(_currentUserService.GetUserId());
            return Ok(result);
        }

        // Read-only base, so delete is declared here rather than inherited. Moderating
        // somebody else's review is an admin action - a user editing their own review
        // is not this endpoint.
        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Authorization("Admin")]
        public async Task<IActionResult> Delete(int id)
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }
    }
}
