using Flix.Model.Enums;
using Flix.Model.Exceptions;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public class NotificationService :
        BaseReadService<
            Notification,
            NotificationResponse,
            NotificationSearchObject>,
        INotificationService
    {
        private const int TitleMaxLength = 100;
        private const int MessageMaxLength = 500;

        private readonly ICurrentUserService _currentUserService;
        private readonly INotificationPublisher _publisher;

        public NotificationService(
            FlixDbContext context,
            IMapper mapper,
            ICurrentUserService currentUserService,
            INotificationPublisher publisher)
            : base(context, mapper)
        {
            _currentUserService = currentUserService;
            _publisher = publisher;
        }

        protected override IQueryable<Notification> GetDataSource()
        {
            var userId = _currentUserService.GetUserId();

            return _context.Set<Notification>()
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.CreatedAt)
                .ThenByDescending(x => x.Id);
        }

        protected override NotificationResponse MapToResponse(Notification entity)
        {
            var response = base.MapToResponse(entity);

            response.CreatedAt = DateTime.SpecifyKind(response.CreatedAt, DateTimeKind.Utc);

            if (response.ReadAt is DateTime readAt)
                response.ReadAt = DateTime.SpecifyKind(readAt, DateTimeKind.Utc);

            return response;
        }

        protected override IEnumerable<Notification> ApplyFilters(IQueryable<Notification> query, NotificationSearchObject? search)
        {
            if (search is null)
                return query;

            if (search.IsRead is bool isRead)
                query = isRead
                    ? query.Where(x => x.ReadAt != null)
                    : query.Where(x => x.ReadAt == null);

            if (search.Type is NotificationType type)
                query = query.Where(x => x.Type == type);

            return query;
        }

        public async Task<NotificationCountResponse> GetUnreadCountAsync()
            => new NotificationCountResponse
            {
                UnreadCount = await CountUnreadAsync(_currentUserService.GetUserId())
            };

        public Task<int> GetUnreadCountForAsync(int userId) => CountUnreadAsync(userId);

        public async Task<NotificationResponse> MarkAsReadAsync(int id)
        {
            var userId = _currentUserService.GetUserId();

            var entity = await _context.Notifications
                .FirstOrDefaultAsync(x => x.Id == id && x.UserId == userId)
                ?? throw new ClientException($"Notification with Id {id} not found.");

            if (entity.ReadAt is null)
            {
                entity.ReadAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                await PublishUnreadCountAsync(userId);
            }

            return MapToResponse(entity);
        }

        public async Task<NotificationCountResponse> MarkAllAsReadAsync()
        {
            var userId = _currentUserService.GetUserId();

            var readAt = DateTime.UtcNow;

            var updated = await _context.Notifications
                .Where(x => x.UserId == userId && x.ReadAt == null)
                .ExecuteUpdateAsync(x => x.SetProperty(n => n.ReadAt, readAt));

            if (updated > 0)
                await PublishUnreadCountAsync(userId);

            return new NotificationCountResponse { UnreadCount = 0 };
        }

        public async Task NotifyAsync(
            int userId,
            NotificationType type,
            string title,
            string message,
            int? movieRequestId = null,
            int? movieId = null)
        {
            var entity = new Notification
            {
                UserId = userId,
                Type = type,
                Title = Truncate(title, TitleMaxLength),
                Message = Truncate(message, MessageMaxLength),
                CreatedAt = DateTime.UtcNow,
                MovieRequestId = movieRequestId,
                MovieId = movieId
            };

            _context.Notifications.Add(entity);

            await _context.SaveChangesAsync();

            await PublishAsync(userId, entity);
        }

        public async Task NotifyAdminsAsync(
            NotificationType type,
            string title,
            string message,
            int? movieRequestId = null,
            int? movieId = null,
            int? exceptUserId = null)
        {
            var adminIds = await _context.Users
                .Where(x => x.IsActive
                    && x.Id != exceptUserId
                    && x.Roles.Any(role => role.Role.IsActive && role.Role.Name == "Admin"))
                .Select(x => x.Id)
                .ToListAsync();

            if (adminIds.Count == 0)
                return;

            var createdAt = DateTime.UtcNow;

            var entities = adminIds.Select(adminId => new Notification
            {
                UserId = adminId,
                Type = type,
                Title = Truncate(title, TitleMaxLength),
                Message = Truncate(message, MessageMaxLength),
                CreatedAt = createdAt,
                MovieRequestId = movieRequestId,
                MovieId = movieId
            }).ToList();

            _context.Notifications.AddRange(entities);

            await _context.SaveChangesAsync();

            foreach (var entity in entities)
                await PublishAsync(entity.UserId, entity);
        }

        private async Task PublishAsync(int userId, Notification entity)
            => await _publisher.PublishAsync(
                userId,
                MapToResponse(entity),
                await CountUnreadAsync(userId));

        private async Task PublishUnreadCountAsync(int userId)
            => await _publisher.PublishUnreadCountAsync(userId, await CountUnreadAsync(userId));

        private Task<int> CountUnreadAsync(int userId)
            => _context.Notifications.CountAsync(x => x.UserId == userId && x.ReadAt == null);

        private static string Truncate(string value, int maxLength)
        {
            var trimmed = (value ?? string.Empty).Trim();

            return trimmed.Length <= maxLength ? trimmed : trimmed[..maxLength];
        }
    }
}
