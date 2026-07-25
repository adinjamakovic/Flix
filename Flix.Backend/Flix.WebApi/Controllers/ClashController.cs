using Flix.Model.Access;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class ClashController
        : BaseCRUDController<ClashResponse, ClashSearchObject, ClashInsertRequest, ClashUpdateRequest, IClashService>
    {

        public ClashController(IClashService clashService) : base(clashService)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<ActionResult<PageResult<ClashResponse>>> Get([FromQuery] ClashSearchObject? search)
        {   
            return Ok(await _service.GetAsync(search));
        }
    }
}