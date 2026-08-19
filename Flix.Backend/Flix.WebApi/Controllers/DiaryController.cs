using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    // Reads only. A diary entry is written by the flow that logs the movie, through
    // IDiaryService, so there is nothing here for a client to post.
    [ApiController]
    [Authorize]
    [Route("[controller]")]
    public class DiaryController : ControllerBase
    {
        private readonly IDiaryService _service;

        public DiaryController(IDiaryService service)
        {
            _service = service;
        }

        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<PageResult<ReviewResponse>>> GetUserDiary([FromQuery] DiarySearchObject? search)
        {
            return Ok(await _service.GetUserDiaryAsync(search));
        }
    }
}
