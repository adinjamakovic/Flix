using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
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
        public async Task<ActionResult<PageResult<ReviewResponse>>> GetLatestFromFriends()
        {
            var result = await _service.GetLatestReviewsFromFriendsAsync(_currentUserService.GetUserId());
            return Ok(result);
        }

        [HttpGet("UserReviewCount")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<ReviewCountResponse>> GetUserReviewCount()
        {
            var result = await _service.GetReviewCountAsync(
                new ReviewCountSearchObject { UserId = _currentUserService.GetUserId() });

            return Ok(result);
        }

        [HttpGet("MovieReviewCount")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<ReviewCountResponse>> GetMovieReviewCount([FromQuery] int movieId)
        {
            var result = await _service.GetReviewCountAsync(
                new ReviewCountSearchObject { MovieId = movieId });

            return Ok(result);
        }

        [HttpGet("MovieState")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<MovieUserStateResponse>> GetMovieState([FromQuery] int movieId)
        {
            return Ok(await _service.GetMovieStateAsync(movieId));
        }

        [HttpPost("StandingReview")]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<MovieUserStateResponse>> UpsertStandingReview([FromForm] ReviewUpsertRequest request)
        {
            return Ok(await _service.UpsertStandingReviewAsync(request));
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
