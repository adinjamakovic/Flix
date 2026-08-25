using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class CastMemberController
        : BaseCRUDController<CastMemberResponse, CastMemberSearchObject, CastMemberInsertRequest, CastMemberUpdateRequest, ICastMemberService>
    {

        public CastMemberController(ICastMemberService castMemberService) : base(castMemberService)
        {
        }

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Consumes("multipart/form-data")]
        [Authorization("Admin")]
        public override async Task<ActionResult<CastMemberResponse>> Create([FromForm] CastMemberInsertRequest request)
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
        public override async Task<ActionResult<CastMemberResponse>> Update(int id, [FromForm] CastMemberUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);
            return result;
        }

        [Authorization("Admin")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}