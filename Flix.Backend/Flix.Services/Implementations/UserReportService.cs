using Flix.Model.Enums;
using Flix.Model.Exceptions;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using Flix.Services.StateMachines;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    // Reports are created through UserNetworkService.ReportAsync, so the only write
    // this side carries is the admin's review of one.
    public class UserReportService(
        FlixDbContext context,
        IMapper mapper,
        IValidator<UserReportUpdateRequest> updateValidator,
        ICurrentUserService currentUserService,
        IResponseImageUrlResolver imageUrlResolver,
        INotificationService notificationService) :
        BaseReadService<
            UserReport,
            UserReportResponse,
            UserReportSearchObject
            >(context, mapper), IUserReportService
    {
        private readonly IValidator<UserReportUpdateRequest> _updateValidator = updateValidator;
        private readonly ICurrentUserService _currentUserService = currentUserService;
        private readonly IResponseImageUrlResolver _imageUrlResolver = imageUrlResolver;
        private readonly INotificationService _notificationService = notificationService;

        protected override UserReportResponse MapToResponse(UserReport entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response.Reporter);
            _imageUrlResolver.Resolve(response.ReportedUser);
            _imageUrlResolver.Resolve(response.ReviewedBy);

            return response;
        }

        protected override IQueryable<UserReport> GetDataSource()
        {
            var query = _context.UserReports.AsQueryable();

            if (!_currentUserService.IsAdmin)
            {
                var userId = _currentUserService.GetUserId();
                query = query.Where(x => x.ReporterId == userId);
            }

            return query
                .OrderByDescending(x => x.CreatedAt)
                .ThenByDescending(x => x.Id)
                .AsSplitQuery();
        }

        protected override Task<IQueryable<UserReport>> IncludeRelatedEntities(UserReportSearchObject? search, IQueryable<UserReport> query)
        {
            if (search?.IncludeReporter == true)
                query = query.Include(x => x.Reporter);

            if (search?.IncludeReportedUser == true)
                query = query.Include(x => x.ReportedUser);

            if (search?.IncludeReviewedBy == true)
                query = query.Include(x => x.ReviewedBy);

            return base.IncludeRelatedEntities(search, query);
        }

        protected override IEnumerable<UserReport> ApplyFilters(IQueryable<UserReport> query, UserReportSearchObject? search)
        {
            if (search is null)
                return query;

            if (search.ReporterId is int reporterId)
                query = query.Where(x => x.ReporterId == reporterId);

            if (search.ReportedUserId is int reportedUserId)
                query = query.Where(x => x.ReportedUserId == reportedUserId);

            if (search.Status is ReportStatus status)
                query = query.Where(x => x.Status == status);

            return query;
        }

        public async Task<UserReportResponse> ReviewAsync(int id, UserReportUpdateRequest request)
        {
            await _updateValidator.ValidateAndThrowAsync(request);

            var entity = await _context.UserReports.FirstOrDefaultAsync(x => x.Id == id)
                ?? throw new ClientException($"{nameof(UserReport)} with Id {id} not found.");

            if (request.AdminComment != null)
                entity.AdminComment = Normalize(request.AdminComment);

            var reviewed = false;

            if (request.Status is ReportStatus status && status != entity.Status)
            {
                Transitions.Report.EnsureCanTransition(
                    entity.Status,
                    status,
                    $"A report that is {entity.Status} cannot be set to {status}.");

                entity.Status = status;
                entity.ReviewedByUserId = _currentUserService.GetUserId();
                entity.ResolvedAt = DateTime.UtcNow;

                reviewed = true;
            }

            await _context.SaveChangesAsync();

            if (reviewed)
                await _notificationService.NotifyAsync(
                    entity.ReporterId,
                    NotificationType.UserReportReviewed,
                    ReportNotificationText.Title(entity.Status),
                    ReportNotificationText.Message(entity.Header, entity.Status, entity.AdminComment));

            return await GetByIdAsync(id);
        }

        public override async Task<UserReportResponse> GetByIdAsync(int id)
        {
            var entity = await GetDataSource()
                .Include(x => x.Reporter)
                .Include(x => x.ReportedUser)
                .Include(x => x.ReviewedBy)
                .FirstOrDefaultAsync(x => x.Id == id)
                ?? throw new ClientException($"{nameof(UserReport)} with Id {id} not found.");

            return MapToResponse(entity);
        }

        private static string? Normalize(string? value)
            => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
    }
}
