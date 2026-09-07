using Flix.Model.Responses;

namespace Flix.Services.Interfaces
{
    public interface INotificationPublisher
    {
        Task PublishAsync(int userId, NotificationResponse notification, int unreadCount);
        Task PublishUnreadCountAsync(int userId, int unreadCount);
    }
}
