using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class MovieController
        : BaseCRUDController<MovieResponse, MovieSearchObject, MovieInsertRequest, MovieUpdateRequest, IMovieService>
    {

        public MovieController(IMovieService movieService) : base(movieService)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<ActionResult<PageResult<MovieResponse>>> Get([FromQuery] MovieSearchObject? search)
        {
            return Ok(await _service.GetAsync(search));
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<ActionResult<MovieResponse>> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}
