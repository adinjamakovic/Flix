using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class GenreController
        : BaseCRUDController<GenreResponse, GenreSearchObject, GenreInsertRequest, GenreUpdateRequest, IGenreService>
    {

        public GenreController(IGenreService genreService) : base(genreService)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<ActionResult<PageResult<GenreResponse>>> Get([FromQuery] GenreSearchObject? search)
        {
            return Ok(await _service.GetAsync(search));
        }
    }
}
