using Flix.Model.Responses;
using Flix.Services.Interfaces;
using Flix.WebApi.Hubs;
using Microsoft.AspNetCore.SignalR;

namespace Flix.WebApi.Services.Notifications
{
    public class SignalRNotificationPublisher : INotificationPublisher
    {
        private readonly IHubContext<NotificationHub> _hub;
        private readonly ILogger<SignalRNotificationPublisher> _logger;

        public SignalRNotificationPublisher(
            IHubContext<NotificationHub> hub,
            ILogger<SignalRNotificationPublisher> logger)
        {
            _hub = hub;
            _logger = logger;
        }

        public Task PublishAsync(int userId, NotificationResponse notification, int unreadCount)
            => SendAsync(userId, "notificationReceived", notification, unreadCount);

        public Task PublishUnreadCountAsync(int userId, int unreadCount)
            => SendAsync(userId, "unreadCountChanged", unreadCount);

        private async Task SendAsync(int userId, string method, params object?[] arguments)
        {
            try
            {
                await _hub.Clients.Group(NotificationHub.GroupFor(userId)).SendCoreAsync(method, arguments);
            }
            catch (Exception e)
            {
                _logger.LogWarning(e, "Could not push {Method} to user {UserId}", method, userId);
            }
        }
    }
}
