using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
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

        // Multipart rather than JSON to match every other write endpoint, and the mobile client's
        // BaseProvider along with them.
        [HttpPost]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<ReviewResponse>> AddToDiary([FromForm] DiaryInsertRequest request)
        {
            return Ok(await _service.AddToDiaryAsync(request));
        }
    }
}
