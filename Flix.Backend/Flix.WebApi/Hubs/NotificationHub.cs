using Flix.Services.Interfaces;
using Flix.WebApi.Extensions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Flix.WebApi.Hubs
{
    [Authorize]
    public class NotificationHub : Hub
    {
        private readonly INotificationService _service;

        public NotificationHub(INotificationService service)
        {
            _service = service;
        }

        public static string GroupFor(int userId) => $"user-{userId}";

        public override async Task OnConnectedAsync()
        {
            var userId = Context.User.GetUserId();

            if (userId is null)
            {
                Context.Abort();
                return;
            }

            await Groups.AddToGroupAsync(Context.ConnectionId, GroupFor(userId.Value));

            await Clients.Caller.SendAsync(
                "unreadCountChanged",
                await _service.GetUnreadCountForAsync(userId.Value));

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userId = Context.User.GetUserId();

            if (userId is not null)
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, GroupFor(userId.Value));

            await base.OnDisconnectedAsync(exception);
        }

        public Task<int> GetUnreadCount()
        {
            var userId = Context.User.GetUserId();

            return userId is null
                ? Task.FromResult(0)
                : _service.GetUnreadCountForAsync(userId.Value);
        }
    }
}
