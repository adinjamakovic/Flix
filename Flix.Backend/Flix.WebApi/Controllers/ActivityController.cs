using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    // Reads only. Activities are written by the services that cause them, through
    // IActivityService, so there is nothing here for a client to post.
    [ApiController]
    [Authorize]
    [Route("[controller]")]
    public class ActivityController : ControllerBase
    {
        private readonly IActivityService _service;

        public ActivityController(IActivityService service)
        {
            _service = service;
        }
        
        [HttpGet]
        [Authorization("Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<PageResult<ActivityResponse>>> GetAll([FromQuery] ActivitySearchObject? search)
        {
            return Ok(await _service.GetAsync(search));
        }

        [HttpGet("FromFollowers")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<PageResult<ActivityResponse>>> GetFromFollowers([FromQuery] ActivitySearchObject? search)
        {
            return Ok(await _service.GetFromFollowersAsync(search));
        }

        [HttpGet("FromSelf")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<PageResult<ActivityResponse>>> GetFromSelf([FromQuery] ActivitySearchObject? search)
        {
            return Ok(await _service.GetFromSelfAsync(search));
        }
    }
}
