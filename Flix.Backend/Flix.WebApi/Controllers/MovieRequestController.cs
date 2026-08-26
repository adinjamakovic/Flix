using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class MovieRequestController :
        BaseReadController<
            MovieRequestResponse,
            MovieRequestSearchObject,
            IMovieRequestService>
    {
        public MovieRequestController(IMovieRequestService service) : base(service)
        {
        }

        // Both reads are the admin review queue: they expose every user's submission along
        // with the disabled movie behind it, so they are not for the user who sent one.
        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public override async Task<ActionResult<PageResult<MovieRequestResponse>>> Get([FromQuery] MovieRequestSearchObject? search)
        {
            return await base.Get(search);
        }

        [HttpGet("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public override async Task<ActionResult<MovieRequestResponse>> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpPost("UserRequest")]
        [Consumes("multipart/form-data")]
        public async Task<ActionResult<MovieResponse>> UserRequest([FromForm] MovieRequestInsertRequest request)
        {
            var result = await _service.UserRequest(request);
            return Ok(result);
        }

        [HttpPut("AdminReview/{id}")]
        [Authorization("Admin")]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<MovieRequestResponse>> AdminReview(int id, [FromForm] MovieRequestUpdateRequest request)
        {
            var result = await _service.AdminReview(id, request);
            return Ok(result);
        }

        // The requester withdrawing their own submission, so it carries no role filter; the
        // service is what keeps every caller, admin included, inside their own submissions.
        [HttpPost("Cancel/{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<MovieRequestResponse>> Cancel(int id)
        {
            var result = await _service.Cancel(id);
            return Ok(result);
        }
    }

}