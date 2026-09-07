using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class MovieController
        : BaseCRUDController<MovieResponse, MovieSearchObject, MovieInsertRequest, MovieUpdateRequest, IMovieService>
    {
        private readonly ICurrentUserService _currentUserService;

        public MovieController(IMovieService movieService, ICurrentUserService currentUserService) : base(movieService)
        {
            _currentUserService = currentUserService;
        }

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Consumes("multipart/form-data")]
        [Authorization("Admin")]
        public override async Task<ActionResult<MovieResponse>> Create([FromForm] MovieInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return result;
        }

        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Consumes("multipart/form-data")]
        [Authorization("Admin")]
        public override async Task<ActionResult<MovieResponse>> Update(int id, [FromForm] MovieUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);
            return result;
        }

        [Authorization("Admin")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }

        [HttpGet("PopularThisWeek")]
        public async Task<ActionResult<PageResult<MovieResponse>>> GetPopularThisWeek([FromQuery] int numberOfMovies = 7)
        {
            var result = await _service.GetPopularMoviesForThisWeekAsync(numberOfMovies);
            return Ok(result);
        }
        [HttpGet("PopularWithFriends")]
        public async Task<ActionResult<PageResult<MovieResponse>>> GetPopularWithFriends()
        {
            var result = await _service.GetPopularMoviesWithFriendsAsync(_currentUserService.GetUserId());
            return Ok(result);   
        }
    }
}
