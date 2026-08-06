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

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Consumes("multipart/form-data")]
        public override async Task<ActionResult<StudioResponse>> Create([FromForm] StudioInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return result;
        }

        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Consumes("multipart/form-data")]
        public override async Task<ActionResult<StudioResponse>> Update(int id, [FromForm] StudioUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);
            return result;
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<ActionResult<PageResult<StudioResponse>>> Get([FromQuery] StudioSearchObject? search)
        {
            return Ok(await _service.GetAsync(search));
        }
    }
}
