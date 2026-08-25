using Flix.Model.Enums;
using Flix.Model.Exceptions;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public class ClashEntryService
        : BaseReadService<ClashEntry, ClashEntryResponse, ClashEntrySearchObject>, IClashEntryService
    {
        public const int VotesPerClash = 5;

        private readonly IResponseImageUrlResolver _imageUrlResolver;
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityService _activityService;

        public ClashEntryService(FlixDbContext context, IMapper mapper, IResponseImageUrlResolver imageUrlResolver, ICurrentUserService currentUserService, IActivityService activityService)
            : base(context, mapper)
        {
            _imageUrlResolver = imageUrlResolver;
            _currentUserService = currentUserService;
            _activityService = activityService;
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

        public async Task Participate(ClashEntryInsertRequest request)
        {
            var participantId = _currentUserService.GetUserId();

            var clash = await _context.Clashes
                .Where(x=> x.Id == request.ClashId && x.StartDate <= DateTime.UtcNow && x.EndDate >= DateTime.UtcNow)
                .FirstOrDefaultAsync();

            if(clash is null)
                throw new ClientException("This clash cannot be entered");

            if(await IsUserInClash(clash.Id, participantId))
                throw new ClientException("Cant enter a clash twice");

            var movieList = await _context.MovieLists
                .Where(x=> x.UserId == participantId && x.Id == request.MovieListId && x.Type != ListType.Watchlist)
                .FirstOrDefaultAsync();


            if(movieList is null)
                throw new ClientException("Can't add this list as a contender");
            
            movieList.Type = ListType.Clash;
            movieList.Name = clash.Name;
            
            var clashEntry = new ClashEntry
            {
                Clash = clash,
                MovieList = movieList,
                UserId = participantId
            };

            _context.ClashEntries.Add(clashEntry);

            await _context.SaveChangesAsync();

            await _activityService.InsertAsync(participantId, new ActivityInsertRequest
            {
                Type = ActivityType.JoinedClash,
                ClashId = clash.Id,
                MovieListId = movieList.Id
            });
        }

        private async Task<bool> IsUserInClash(int id, int participantId)
        {
            return await _context.ClashEntries
                .AnyAsync(x => x.UserId == participantId && x.ClashId == id);
        }

        public async Task<ClashVoteStateResponse> GetVoteStateAsync(int clashId)
        {
            var votedEntryIds = await _context.ClashVotes
                .Where(x => x.ClashEntry.ClashId == clashId && x.VoterId == _currentUserService.GetUserId())
                .Select(x => x.ClashEntryId)
                .ToListAsync();

            return new ClashVoteStateResponse
            {
                ClashId = clashId,
                VotesAllowed = VotesPerClash,
                VotesUsed = votedEntryIds.Count,
                VotesRemaining = Math.Max(VotesPerClash - votedEntryIds.Count, 0),
                VotedEntryIds = votedEntryIds
            };
        }

        public async Task<int> CalculateUserVotesAsync(int clashId, int participantId)
        {
            return await _context.ClashVotes
                .Where(x => x.ClashEntry.ClashId == clashId && x.VoterId == participantId)
                .CountAsync();
        }

        public async Task Vote(int clashEntryId)
        {
            var voterId = _currentUserService.GetUserId();

            var entry = await _context.ClashEntries
                .Include(x => x.Clash)
                .FirstOrDefaultAsync(x => x.Id == clashEntryId);

            if(entry is null)
                throw new ClientException("This entry cannot be voted on");

            if(entry.Clash.StartDate > DateTime.UtcNow || entry.Clash.EndDate < DateTime.UtcNow)
                throw new ClientException("This clash is not open for voting");

            if(entry.UserId == voterId)
                throw new ClientException("Can't vote for your own entry");

            if(await CalculateUserVotesAsync(entry.ClashId, voterId) >= VotesPerClash)
                throw new ClientException("You have no votes left in this clash");

            _context.ClashVotes.Add(new ClashVote
            {
                ClashEntryId = entry.Id,
                VoterId = voterId
            });

            await _context.SaveChangesAsync();

            await _activityService.InsertAsync(voterId, new ActivityInsertRequest
            {
                Type = ActivityType.VotedOnClash,
                ClashId = entry.ClashId,
                MovieListId = entry.MovieListId
            });
        }

        public async Task RemoveVote(int clashEntryId)
        {
            var voterId = _currentUserService.GetUserId();

            var vote = await _context.ClashVotes
                .Include(x => x.ClashEntry)
                    .ThenInclude(e => e.Clash)
                .FirstOrDefaultAsync(x => x.ClashEntryId == clashEntryId && x.VoterId == voterId);

            if(vote is null)
                throw new ClientException("You have not voted on this entry");

            if(vote.ClashEntry.Clash.EndDate < DateTime.UtcNow)
                throw new ClientException("This clash has ended, its votes can no longer be taken back");

            _context.ClashVotes.Remove(vote);

            await RemoveVoteActivitiesAsync(voterId, vote.ClashEntry.ClashId);

            await _context.SaveChangesAsync();
        }

        private async Task RemoveVoteActivitiesAsync(int voterId, int clashId)
        {
            var activities = await _context.Activities
                .Where(x => x.Type == ActivityType.VotedOnClash
                    && x.UserId == voterId
                    && x.ClashId == clashId)
                .ToListAsync();

            _context.Activities.RemoveRange(activities);
        }
    }
}
