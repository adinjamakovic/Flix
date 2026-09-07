using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Flix.WebApi.Controllers
{
    public class NotificationController :
        BaseReadController<
            NotificationResponse,
            NotificationSearchObject,
            INotificationService>
    {
        public NotificationController(INotificationService service) : base(service)
        {
        }

        [HttpGet("UnreadCount")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<NotificationCountResponse>> GetUnreadCount()
        {
            return Ok(await _service.GetUnreadCountAsync());
        }

        [HttpPut("MarkAsRead/{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<NotificationResponse>> MarkAsRead(int id)
        {
            return Ok(await _service.MarkAsReadAsync(id));
        }

        [HttpPut("MarkAllAsRead")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<NotificationCountResponse>> MarkAllAsRead()
        {
            return Ok(await _service.MarkAllAsReadAsync());
        }
    }
}
