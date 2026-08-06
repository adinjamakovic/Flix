using Flix.Model.Exceptions;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    // Entries are only ever read. A clash belongs to its participants once it is
    // running, so nothing here writes - the admin client just looks at how the
    // entries are placing.
    public class ClashEntryService
        : BaseReadService<ClashEntry, ClashEntryResponse, ClashEntrySearchObject>, IClashEntryService
    {
        private readonly IResponseImageUrlResolver _imageUrlResolver;

        public ClashEntryService(FlixDbContext context, IMapper mapper, IResponseImageUrlResolver imageUrlResolver)
            : base(context, mapper)
        {
            _imageUrlResolver = imageUrlResolver;
        }

        // The entry itself has no image, but the participant it belongs to has an avatar.
        protected override ClashEntryResponse MapToResponse(ClashEntry entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response);

            return response;
        }

        // This is a leaderboard, so the entries come back best-first and the client
        // reads a row's rank straight off its position in the page. Ties go to
        // whoever entered first; the Id keeps paging deterministic beyond that.
        // Votes are always loaded because the response counts them.
        protected override IQueryable<ClashEntry> GetDataSource()
            => _context.Set<ClashEntry>()
                .Include(e => e.Votes)
                .OrderByDescending(e => e.Votes.Count)
                .ThenBy(e => e.CreatedAt)
                .ThenBy(e => e.Id)
                .AsSplitQuery();

        protected override Task<IQueryable<ClashEntry>> IncludeRelatedEntities(ClashEntrySearchObject? search, IQueryable<ClashEntry> query)
        {
            if (search?.IncludeUser == true)
                query = query.Include(e => e.User);

            // The items come along with the list because the response carries the
            // number of movies on it, counted off what was loaded.
            if (search?.IncludeMovieList == true)
                query = query.Include(e => e.MovieList)
                    .ThenInclude(l => l.Items);

            return base.IncludeRelatedEntities(search, query);
        }

        protected override IEnumerable<ClashEntry> ApplyFilters(IQueryable<ClashEntry> query, ClashEntrySearchObject? search)
        {
            if (search is null)
                return query;

            if (search.ClashId is int clashId)
                query = query.Where(e => e.ClashId == clashId);

            if (!string.IsNullOrWhiteSpace(search.Username?.Trim()))
            {
                var username = search.Username.Trim().ToLower();
                query = query.Where(e => e.User.Username.ToLower().Contains(username));
            }

            return query;
        }

        // The base implementation goes through FindAsync, which would skip the
        // includes and hand back an entry with no user, list or votes.
        public override async Task<ClashEntryResponse> GetByIdAsync(int id)
        {
            var entity = await GetDataSource()
                .Include(e => e.User)
                .Include(e => e.MovieList)
                    .ThenInclude(l => l.Items)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (entity is null)
                throw new ClientException($"{nameof(ClashEntry)} with Id {id} not found.");

            return MapToResponse(entity);
        }
    }
}
