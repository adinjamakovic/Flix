using System.Diagnostics;
using System.Net.Quic;
using System.Security.Cryptography.X509Certificates;
using Flix.Model.Enums;
using Flix.Model.Exceptions;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace Flix.Services.Implementations
{
    public class ListService :
        BaseCRUDService<
            MovieList,
            ListResponse,
            ListSearchObject,
            ListInsertRequest,
            ListUpdateRequest>, IListService
    {
        private const string WatchlistName = "Watchlist";

        public ICurrentUserService _currentUserService;
        private readonly IResponseImageUrlResolver _imageUrlResolver;
        private readonly IActivityService _activityService;
        public ListService(
            FlixDbContext context,
            IMapper mapper,
            IValidator<ListInsertRequest> insertValidator,
            IValidator<ListUpdateRequest> updateValidator,
            ICurrentUserService currentUserService,
            IResponseImageUrlResolver imageUrlResolver,
            IActivityService activityService) : base(context, mapper, insertValidator, updateValidator)
        {
            _currentUserService = currentUserService;
            _imageUrlResolver = imageUrlResolver;
            _activityService = activityService;
        }

        // The list carries no image itself, but the owner's avatar and the posters of the movies
        // on it are stored blob paths until they go through the resolver.
        protected override ListResponse MapToResponse(MovieList entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response);

            return response;
        }

        protected override IEnumerable<MovieList> ApplyFilters(IQueryable<MovieList> query, ListSearchObject? search)
        {
            if(search?.UserId > 0)
                query = query.Where(x=> x.UserId == search.UserId);

            // Search over List name is case insensitive
            if(!string.IsNullOrWhiteSpace(search?.Name?.Trim()))
                query = query.Where(x=>x.Name.ToLower().Contains(search.Name.ToLower().Trim()));

            if(search?.Type != null)
                query = query.Where(x=>x.Type == search.Type);

            return query;
        }

        public override async Task<ListResponse> GetByIdAsync(int id)
        {
            var entity = await GetDataSource()
                .Include(x => x.User)
                .Include(x => x.Items.OrderBy(i => i.Position))
                    .ThenInclude(x => x.Movie)
                .FirstOrDefaultAsync(x => x.Id == id);

            if(entity is null)
                throw new ClientException($"{nameof(MovieList)} with Id {id} not found.");

            return MapToResponse(entity);
        }

        protected override async Task<IQueryable<MovieList>> IncludeRelatedEntities(ListSearchObject? search, IQueryable<MovieList> query)
        {
            if(search?.IncludeMovies == true)
                query = query.
                    Include(x => x.Items.OrderBy(i => i.Position)).
                        ThenInclude(x => x.Movie);

            if(search?.IncludeUser == true)
                query = query.
                    Include(x=>x.User);

            return query;
        }

        protected override async Task BeforeInsertAsync(MovieList entity, ListInsertRequest request)
        {
            entity.UserId = _currentUserService.GetUserId();
            entity.Type = ListType.Custom;
            entity.CreatedAt = DateTime.UtcNow;

            if(request.MovieIds is null || request.MovieIds.Count == 0)
                return;

            var requestedIds = request.MovieIds?.Distinct().ToList() ?? new List<int>();

            for(var position = 0; position < requestedIds.Count; position++)
            {
                var id = requestedIds[position];

                var movie = await _context.Movies.Where(x=>x.Id == id).FirstOrDefaultAsync();

                if(movie is null)
                    throw new ClientException("One of the selected movies is null");

                var MovieListItem = new MovieListItem
                {
                    MovieId = id,
                    MovieList = entity,
                    Position = position
                };

                _context.MovieListItems.Add(MovieListItem);
            }
        }

        protected override async Task BeforeUpdateAsync(MovieList entity, ListUpdateRequest request)
        {
            if(_currentUserService.GetUserId() != entity.UserId)
                throw new ClientException("Only the user who made the list can edit the list");

            entity.UpdatedAt = DateTime.UtcNow;

            var requestedIds = request.MovieIds?.Distinct().ToList() ?? new List<int>();

            var existingItems = await _context.MovieListItems
                .Where(x => x.MovieListId == entity.Id)
                .ToListAsync();

            var removedItems = existingItems.Where(x => !requestedIds.Contains(x.MovieId)).ToList();

            if(removedItems.Count > 0)
                _context.MovieListItems.RemoveRange(removedItems);

            var existingMovieIds = existingItems.Select(x => x.MovieId).ToHashSet();
            var addedMovieIds = requestedIds.Where(x => !existingMovieIds.Contains(x)).ToList();

            var validMovieIds = addedMovieIds.Count == 0
                ? new List<int>()
                : await _context.Movies
                    .Where(x => addedMovieIds.Contains(x.Id))
                    .Select(x => x.Id)
                    .ToListAsync();

            for(var position = 0; position < requestedIds.Count; position++)
            {
                var id = requestedIds[position];

                var existingItem = existingItems.FirstOrDefault(x => x.MovieId == id);

                if(existingItem is not null)
                {
                    existingItem.Position = position;
                    continue;
                }

                if(!validMovieIds.Contains(id))
                    throw new ClientException("One of the selected movies is null");

                var MovieListItem = new MovieListItem
                {
                    MovieId = id,
                    MovieListId = entity.Id,
                    Position = position
                };

                _context.MovieListItems.Add(MovieListItem);
            }
        }

        protected override async Task BeforeDeleteAsync(MovieList entity)
        {
            if(_currentUserService.GetUserId() != entity.UserId)
                throw new ClientException("Only the user who made the list can delete the list");

            if(entity.Type == ListType.Watchlist)
                throw new ClientException("The watchlist cannot be deleted.");

            var items = await _context.MovieListItems
                .Where(x => x.MovieListId == entity.Id)
                .ToListAsync();

            _context.MovieListItems.RemoveRange(items);

            var activities = await _context.Activities
                .Where(x => x.MovieListId == entity.Id)
                .ToListAsync();

            _context.Activities.RemoveRange(activities);

            await RemoveClashEntriesAsync(entity.Id);
        }

        private async Task RemoveClashEntriesAsync(int listId)
        {
            var entries = await _context.ClashEntries
                .Include(x => x.Votes)
                .Where(x => x.MovieListId == listId)
                .ToListAsync();

            if(entries.Count == 0)
                return;

            foreach(var entry in entries)
                _context.ClashVotes.RemoveRange(entry.Votes);

            _context.ClashEntries.RemoveRange(entries);

            var removedEntryIds = entries.Select(x => x.Id).ToHashSet();

            var clashesLosingTheirWinner = entries
                .Where(x => x.IsWinner)
                .Select(x => x.ClashId)
                .Distinct()
                .ToList();

            foreach(var clashId in clashesLosingTheirWinner)
                await ReassignWinnerAsync(clashId, removedEntryIds);
        }

        private async Task ReassignWinnerAsync(int clashId, HashSet<int> removedEntryIds)
        {
            var replacement = await _context.ClashEntries
                .Include(x => x.Votes)
                .Where(x => x.ClashId == clashId && !removedEntryIds.Contains(x.Id))
                .OrderByDescending(x => x.Votes.Count)
                .ThenBy(x => x.CreatedAt)
                .ThenBy(x => x.Id)
                .FirstOrDefaultAsync();

            if(replacement is null || replacement.Votes.Count == 0)
                return;

            replacement.IsWinner = true;
        }

        public async Task AddToWatchlistAsync(int movieId)
        {
            var userId = _currentUserService.GetUserId();

            var movie = await _context.Movies.FirstOrDefaultAsync(x => x.Id == movieId)
                ?? throw new ClientException($"Movie with Id {movieId} not found.");

            if(!movie.IsEnabled)
                throw new ClientException("This movie cannot be added to a watchlist.");

            var watchlist = await GetOrCreateWatchlistAsync(userId);

            if(watchlist.Items.Any(x => x.MovieId == movieId))
                return;

            _context.MovieListItems.Add(new MovieListItem
            {
                MovieList = watchlist,
                MovieId = movieId,
                Position = watchlist.Items.Count == 0 ? 0 : watchlist.Items.Max(x => x.Position) + 1,
                AddedAt = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();

            await _activityService.InsertAsync(userId, new ActivityInsertRequest
            {
                Type = ActivityType.AddedToWatchlist,
                MovieId = movieId,
                MovieListId = watchlist.Id
            });
        }

        // Called both by the watchlist toggle and by logging a movie - a movie that has been
        // watched has no business sitting in the queue of ones that have not.
        public async Task RemoveIfAddedToWatchlistAsync(int movieId)
        {
            var userId = _currentUserService.GetUserId();

            var item = await _context.MovieListItems
                .FirstOrDefaultAsync(x => x.MovieId == movieId
                    && x.MovieList.UserId == userId
                    && x.MovieList.Type == ListType.Watchlist);

            if(item is null)
                return;

            _context.MovieListItems.Remove(item);

            await _context.SaveChangesAsync();
        }

        public async Task<bool> IsInWatchlistAsync(int movieId)
        {
            var userId = _currentUserService.GetUserId();

            return await _context.MovieListItems
                .AnyAsync(x => x.MovieId == movieId
                    && x.MovieList.UserId == userId
                    && x.MovieList.Type == ListType.Watchlist);
        }

        // UserService gives every new account a watchlist, but the seeded users predate that and
        // SeedRecommenderWatchlists only covers some of them.
        private async Task<MovieList> GetOrCreateWatchlistAsync(int userId)
        {
            var watchlist = await _context.MovieLists
                .Include(x => x.Items)
                .FirstOrDefaultAsync(x => x.UserId == userId && x.Type == ListType.Watchlist);

            if(watchlist is not null)
                return watchlist;

            watchlist = new MovieList
            {
                UserId = userId,
                Name = WatchlistName,
                Type = ListType.Watchlist,
                CreatedAt = DateTime.UtcNow
            };

            _context.MovieLists.Add(watchlist);

            await _context.SaveChangesAsync();

            return watchlist;
        }
    }
}