using Flix.Model.Enums;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface INotificationService : IBaseReadService<NotificationResponse, NotificationSearchObject>
    {
        Task<NotificationCountResponse> GetUnreadCountAsync();
        Task<int> GetUnreadCountForAsync(int userId);
        Task<NotificationResponse> MarkAsReadAsync(int id);
        Task<NotificationCountResponse> MarkAllAsReadAsync();

        Task NotifyAsync(
            int userId,
            NotificationType type,
            string title,
            string message,
            int? movieRequestId = null,
            int? movieId = null);

        Task NotifyAdminsAsync(
            NotificationType type,
            string title,
            string message,
            int? movieRequestId = null,
            int? movieId = null,
            int? exceptUserId = null);
    }
}
