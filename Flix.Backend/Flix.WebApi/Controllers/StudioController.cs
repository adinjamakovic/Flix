using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class StudioController
        : BaseCRUDController<StudioResponse, StudioSearchObject, StudioInsertRequest, StudioUpdateRequest, IStudioService>
    {

        public StudioController(IStudioService studioService) : base(studioService)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<ActionResult<PageResult<StudioResponse>>> Get([FromQuery] StudioSearchObject? search)
        {
            return Ok(await _service.GetAsync(search));
        }
    }
}
