using Flix.Model.Access;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Flix.WebApi.Services.AccessManager;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    [ApiController]
    [Authorize]
    [Route("[controller]")]
    public class MovieRecommendationsController : ControllerBase
    {
        private readonly IMovieRecommendationService _movieRecommendationService;
        private readonly ICurrentUserService _currentUserService;
        
        public MovieRecommendationsController(
            IMovieRecommendationService movieRecommendationService,
            ICurrentUserService currentUserService
            )
        {
            _movieRecommendationService = movieRecommendationService;
            _currentUserService = currentUserService;
        }

        [HttpPost("GenerateRecommendations")]
        [Authorization("Admin")]
        public async Task<IActionResult> GenerateRecommendations()
        {
            await _movieRecommendationService.GenerateRecommendationAsync();
            return Ok("Movie recommendations generated succesfully");
        }

        [HttpGet("GetRecommendationsForMovies")]
        public async Task<ActionResult<PageResult<MovieRecommendationResponse>>> GetRecommendationsForMovie([FromQuery] MovieRecommendationSearchObject search)
        {
            var result = await _movieRecommendationService.GetRecommendationsForMovieAsync(search);
            return Ok(result);
        }
        [HttpGet("GetRecommendationsForUser")]
        public async Task<ActionResult<PageResult<MovieRecommendationResponse>>> GetRecommendationsForCurrentUser()
        {
            var result = await _movieRecommendationService.GetRecommendationsForUserAsync(_currentUserService.GetUserId());
            return Ok(result);
        }
        [HttpDelete("DeleteRecommendations")]
        [Authorization("Admin")]
        public async Task<IActionResult> DeleteRecommendations()
        {
            await _movieRecommendationService.DeleteOldRecommendations();
            return Ok("Recommendations deleted succesfully");
        }
    }
}
