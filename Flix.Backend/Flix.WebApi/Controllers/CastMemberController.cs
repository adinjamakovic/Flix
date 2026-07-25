using Flix.Model.Access;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class CastMemberController
        : BaseCRUDController<CastMemberResponse, CastMemberSearchObject, CastMemberInsertRequest, CastMemberUpdateRequest, ICastMemberService>
    {

        public CastMemberController(ICastMemberService castMemberService) : base(castMemberService)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<ActionResult<PageResult<CastMemberResponse>>> Get([FromQuery] CastMemberSearchObject? search)
        {   
            return Ok(await _service.GetAsync(search));
        }
    }
}