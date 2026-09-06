using Flix.Model.Responses;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    [ApiController]
    [Authorize]
    [Route("[controller]")]
    public class MovieRecommendationsController : ControllerBase
    {
        private readonly IUserRecommendationService _userRecommendationService;
        private readonly ICurrentUserService _currentUserService;

        public MovieRecommendationsController(
            IUserRecommendationService userRecommendationService,
            ICurrentUserService currentUserService
            )
        {
            _userRecommendationService = userRecommendationService;
            _currentUserService = currentUserService;
        }

        [HttpGet("GetRecommendationsForUser")]
        public async Task<ActionResult<PageResult<MovieRecommendationResponse>>> GetRecommendationsForCurrentUser()
        {
            var result = await _userRecommendationService.GetRecommendationsForUserAsync(_currentUserService.GetUserId());
            return Ok(result);
        }
    }
}
