using Azure;
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

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Consumes("multipart/form-data")]
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
        public override async Task<ActionResult<MovieResponse>> Update(int id, [FromForm] MovieUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);
            return result;
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
