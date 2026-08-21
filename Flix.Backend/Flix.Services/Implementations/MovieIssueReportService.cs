using Flix.Model.Enums;
using Flix.Model.Exceptions;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public class MovieIssueReportService(
        FlixDbContext context,
        IMapper mapper,
        IValidator<MovieIssueReportInsertRequest> insertValidator,
        IValidator<MovieIssueReportUpdateRequest> updateValidator,
        ICurrentUserService currentUserService,
        IResponseImageUrlResolver imageUrlResolver) :
        BaseCRUDService<
            MovieIssueReport,
            MovieIssueReportResponse,
            MovieIssueReportSearchObject,
            MovieIssueReportInsertRequest,
            MovieIssueReportUpdateRequest
            >(context, mapper, insertValidator, updateValidator), IMovieIssueReportService
    {
        private readonly ICurrentUserService _currentUserService = currentUserService;
        private readonly IResponseImageUrlResolver _imageUrlResolver = imageUrlResolver;

        protected override MovieIssueReportResponse MapToResponse(MovieIssueReport entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response.Movie);
            _imageUrlResolver.Resolve(response.ReportedBy);
            _imageUrlResolver.Resolve(response.ReviewedBy);

            return response;
        }

        protected override IQueryable<MovieIssueReport> GetDataSource()
        {
            var query = _context.MovieIssueReports.AsQueryable();

            if (!_currentUserService.IsAdmin)
            {
                var userId = _currentUserService.GetUserId();
                query = query.Where(x => x.ReportedByUserId == userId);
            }

            return query
                .OrderByDescending(x => x.CreatedAt)
                .ThenByDescending(x => x.Id)
                .AsSplitQuery();
        }

        protected override Task<IQueryable<MovieIssueReport>> IncludeRelatedEntities(MovieIssueReportSearchObject? search, IQueryable<MovieIssueReport> query)
        {
            if (search?.IncludeReportedBy == true)
                query = query.Include(x => x.ReportedBy);

            if (search?.IncludeReviewedBy == true)
                query = query.Include(x => x.ReviewedBy);

            if (search?.IncludeMovie == true)
                query = IncludeMovie(query);

            return base.IncludeRelatedEntities(search, query);
        }

        protected override IEnumerable<MovieIssueReport> ApplyFilters(IQueryable<MovieIssueReport> query, MovieIssueReportSearchObject? search)
        {
            if (search is null)
                return query;

            if (search.UserId is int userId)
                query = query.Where(x => x.ReportedByUserId == userId);

            if (search.Status is ReportStatus status)
                query = query.Where(x => x.Status == status);

            return query;
        }

        protected override async Task BeforeInsertAsync(MovieIssueReport entity, MovieIssueReportInsertRequest request)
        {
            await EnsureMovieExistsAsync(request.MovieId);

            entity.ReportedByUserId = _currentUserService.GetUserId();
            entity.Header = request.Header.Trim();
            entity.Description = Normalize(request.Description);
            entity.Status = ReportStatus.Open;
            entity.CreatedAt = DateTime.UtcNow;
            entity.ReviewedByUserId = null;
            entity.ResolvedAt = null;
            entity.AdminComment = null;
        }

        protected override void MapUpdateRequestToEntity(MovieIssueReportUpdateRequest request, MovieIssueReport entity)
        {
            var isAdmin = _currentUserService.IsAdmin;
            var isOwner = entity.ReportedByUserId == _currentUserService.GetUserId();

            if (!isOwner && !isAdmin)
                throw new ClientException("You can only edit your own reports.");

            if (isOwner)
            {
                if (!isAdmin && entity.Status != ReportStatus.Open)
                    throw new ClientException("A report that has already been reviewed can no longer be edited.");

                entity.MovieId = request.MovieId;
                entity.Header = request.Header.Trim();
                entity.Description = Normalize(request.Description);
            }

            if (!isAdmin)
                return;

            if (request.AdminComment != null)
                entity.AdminComment = Normalize(request.AdminComment);

            if (request.Status is not ReportStatus status || status == entity.Status)
                return;

            entity.Status = status;
            entity.ReviewedByUserId = _currentUserService.GetUserId();
            entity.ResolvedAt = DateTime.UtcNow;
        }

        protected override Task BeforeUpdateAsync(MovieIssueReport entity, MovieIssueReportUpdateRequest request)
        {
            return EnsureMovieExistsAsync(entity.MovieId);
        }

        protected override Task BeforeDeleteAsync(MovieIssueReport entity)
        {
            if (!_currentUserService.IsAdmin && entity.ReportedByUserId != _currentUserService.GetUserId())
                throw new ClientException("You can only delete your own reports.");

            return Task.CompletedTask;
        }

        public override async Task<MovieIssueReportResponse> InsertAsync(MovieIssueReportInsertRequest request)
        {
            var created = await base.InsertAsync(request);

            return await GetByIdAsync(created.Id);
        }

        public override async Task<MovieIssueReportResponse> UpdateAsync(int id, MovieIssueReportUpdateRequest request)
        {
            await base.UpdateAsync(id, request);

            return await GetByIdAsync(id);
        }

        public override async Task<MovieIssueReportResponse> GetByIdAsync(int id)
        {
            var entity = await IncludeMovie(GetDataSource())
                .Include(x => x.ReportedBy)
                .Include(x => x.ReviewedBy)
                .FirstOrDefaultAsync(x => x.Id == id)
                ?? throw new ClientException($"{nameof(MovieIssueReport)} with Id {id} not found.");

            return MapToResponse(entity);
        }

        private async Task EnsureMovieExistsAsync(int movieId)
        {
            if (!await _context.Movies.AnyAsync(x => x.Id == movieId))
                throw new ClientException($"Movie with Id {movieId} not found.");
        }

        private static string? Normalize(string? value)
            => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

        private static IQueryable<MovieIssueReport> IncludeMovie(IQueryable<MovieIssueReport> query)
            => query
                .Include(x => x.Movie).ThenInclude(m => m.Country)
                .Include(x => x.Movie).ThenInclude(m => m.Language)
                .Include(x => x.Movie).ThenInclude(m => m.Genres);
    }
}
