using Flix.Model.Enums;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Recommendations
{
    public class RecommendationSignalService : IRecommendationSignalService
    {
        private readonly FlixDbContext _context;

        public RecommendationSignalService(FlixDbContext context)
        {
            _context = context;
        }

        public async Task<IReadOnlyList<UserMovieSignal>> GetSignalsAsync(CancellationToken cancellationToken = default)
        {
            var reviews = await _context.Reviews
                .Select(review => new { review.UserId, review.MovieId, review.Rating, review.IsLiked })
                .ToListAsync(cancellationToken);

            var watchlistEntries = await _context.MovieListItems
                .Where(item => item.MovieList.Type == ListType.Watchlist)
                .Select(item => new { item.MovieList.UserId, item.MovieId })
                .Distinct()
                .ToListAsync(cancellationToken);

            var watches = await _context.Activities
                .Where(activity => activity.Type == ActivityType.WatchedMovie && activity.MovieId != null)
                .Select(activity => new { activity.UserId, MovieId = activity.MovieId!.Value })
                .Distinct()
                .ToListAsync(cancellationToken);

            var builder = new RecommendationSignalBuilder();

            foreach (var review in reviews)
                builder.AddReview(review.UserId, review.MovieId, review.Rating, review.IsLiked);

            foreach (var entry in watchlistEntries)
                builder.AddWatchlistEntry(entry.UserId, entry.MovieId);

            foreach (var watch in watches)
                builder.AddWatch(watch.UserId, watch.MovieId);

            return builder.Build();
        }

        public async Task<IReadOnlyList<MovieFeatures>> GetMovieFeaturesAsync(
            IReadOnlyCollection<int>? movieIds = null,
            CancellationToken cancellationToken = default)
        {
            var query = _context.Movies.AsQueryable();

            if (movieIds != null)
                query = query.Where(movie => movieIds.Contains(movie.Id));

            // Projected rather than Include'd: the profile only needs ids, and pulling the whole
            // graph of every candidate would load the catalog on every request.
            var attributes = await query
                .Select(movie => new
                {
                    movie.Id,
                    movie.CountryId,
                    movie.LanguageId,
                    movie.ReleaseDate,
                    GenreIds = movie.Genres.Select(genre => genre.Id).ToList(),
                    DirectorIds = movie.Credits
                        .Where(credit => credit.Role == CastRole.Director)
                        .Select(credit => credit.CastMemberId)
                        .ToList(),
                    ActorIds = movie.Credits
                        .Where(credit => credit.Role != CastRole.Director)
                        .OrderBy(credit => credit.OrderOfAppearence)
                        .Select(credit => credit.CastMemberId)
                        .ToList(),
                    StudioIds = movie.Studios.Select(studio => studio.StudioId).ToList()
                })
                .ToListAsync(cancellationToken);

            return attributes
                .Select(movie => MovieFeatures.From(new MovieAttributes(
                    movie.Id,
                    movie.GenreIds,
                    movie.DirectorIds,
                    movie.ActorIds,
                    movie.StudioIds,
                    movie.CountryId,
                    movie.LanguageId,
                    movie.ReleaseDate?.Year)))
                .ToList();
        }
    }
}
