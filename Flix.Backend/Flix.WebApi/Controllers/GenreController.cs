using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class GenreController
        : BaseCRUDController<GenreResponse, GenreSearchObject, GenreInsertRequest, GenreUpdateRequest, IGenreService>
    {

        public GenreController(IGenreService genreService) : base(genreService)
        {
        }

        [Authorization("Admin")]
        public override Task<ActionResult<GenreResponse>> Create([FromBody] GenreInsertRequest request)
        {
            return base.Create(request);
        }

        [Authorization("Admin")]
        public override Task<ActionResult<GenreResponse>> Update(int id, [FromBody] GenreUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorization("Admin")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}
