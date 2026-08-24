using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Flix.WebApi.Filters;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class UserReportController
        : BaseReadController<UserReportResponse, UserReportSearchObject, IUserReportService>
    {
        public UserReportController(IUserReportService service) : base(service)
        {
        }

        [HttpPut("{id}")]
        [Authorization("Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<UserReportResponse>> Review(int id, [FromBody] UserReportUpdateRequest request)
        {
            return Ok(await _service.ReviewAsync(id, request));
        }
    }
}
