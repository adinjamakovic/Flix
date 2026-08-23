using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class ClashEntryController
        : BaseReadController<ClashEntryResponse, ClashEntrySearchObject, IClashEntryService>
    {
        public ClashEntryController(IClashEntryService service) : base(service)
        {
        }

        [HttpPost("Participate")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Participate(ClashEntryInsertRequest request)
        {
            await _service.Participate(request);
            return NoContent();
        }

        [HttpGet("VoteState/{clashId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<ClashVoteStateResponse>> GetVoteState(int clashId)
        {
            return Ok(await _service.GetVoteStateAsync(clashId));
        }

        [HttpPost("Vote/{clashEntryId}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Vote(int clashEntryId)
        {
            await _service.Vote(clashEntryId);
            return NoContent();
        }

        [HttpDelete("Vote/{clashEntryId}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> RemoveVote(int clashEntryId)
        {
            await _service.RemoveVote(clashEntryId);
            return NoContent();
        }
    }
}
