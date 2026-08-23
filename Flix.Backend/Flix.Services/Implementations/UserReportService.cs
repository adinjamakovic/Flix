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
    // Reports are written through UserNetworkService.ReportAsync, so this side only reads them.
    public class UserReportService(
        FlixDbContext context,
        IMapper mapper,
        ICurrentUserService currentUserService,
        IResponseImageUrlResolver imageUrlResolver) :
        BaseReadService<
            UserReport,
            UserReportResponse,
            UserReportSearchObject
            >(context, mapper), IUserReportService
    {
        private readonly ICurrentUserService _currentUserService = currentUserService;
        private readonly IResponseImageUrlResolver _imageUrlResolver = imageUrlResolver;

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
    }
}
