using Flix.Model.Enums;
using Flix.Model.Responses;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using Flix.Services.Recommendations;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public class UserRecommendationService : IUserRecommendationService
    {
        private const int RecommendationCount = 12;
        private const string PopularReason = "Popular on Flix right now";
        private const string NeighbourReason = "Loved by users with taste like yours";
        private const string ProfileReason = "Matches what you have been watching";

        private readonly FlixDbContext _context;
        private readonly IMapper _mapper;
        private readonly IResponseImageUrlResolver _imageUrlResolver;
        private readonly IRecommendationSignalService _signalService;

        public UserRecommendationService(
            FlixDbContext context,
            IMapper mapper,
            IResponseImageUrlResolver imageUrlResolver,
            IRecommendationSignalService signalService)
        {
            _context = context;
            _mapper = mapper;
            _imageUrlResolver = imageUrlResolver;
            _signalService = signalService;
        }

        public async Task<PageResult<MovieRecommendationResponse>> GetRecommendationsForUserAsync(int userId)
        {
            var signals = await _signalService.GetSignalsAsync();
            var ownSignals = signals.Where(signal => signal.UserId == userId).ToList();

            // A recommendation is only useful if it is a discovery, so everything the user has seen
            // or already queued is off the table. Disabled movies still shape the profile and still
            // count towards a neighbour's taste, but they are never offered.
            var excludedMovieIds = ownSignals
                .Where(signal => signal.IsWatched || signal.Affinity > 0)
                .Select(signal => signal.MovieId)
                .ToHashSet();

            var candidates = await _context.Movies
                .Where(movie => movie.IsEnabled && !excludedMovieIds.Contains(movie.Id))
                .Select(movie => new PopularityCandidate(movie.Id, movie.Views))
                .ToListAsync();

            if (candidates.Count == 0)
                return Page([]);

            var features = await LoadFeaturesAsync(candidates, ownSignals);
            var candidateMovieIds = candidates.Select(candidate => candidate.MovieId).ToList();

            var ranked = HybridRecommender
                .Recommend(userId, signals, features, candidateMovieIds, RecommendationCount)
                .Select(score => (Score: score, Source: RecommendationSource.Similar))
                .ToList();

            // A profile that only overlaps a handful of the catalog leaves the row half empty, and a
            // half empty row on the home screen reads as a bug rather than as a short list.
            if (ranked.Count < RecommendationCount)
            {
                var alreadyRanked = ranked.Select(entry => entry.Score.MovieId).ToHashSet();

                ranked.AddRange(HybridRecommender
                    .RankByPopularity(
                        signals,
                        candidates.Where(candidate => !alreadyRanked.Contains(candidate.MovieId)).ToList(),
                        RecommendationCount - ranked.Count)
                    .Select(score => (Score: score, Source: RecommendationSource.Popular)));
            }

            var movies = await LoadMovieResponsesAsync(ranked.Select(entry => entry.Score));

            return Page(ranked
                .Where(entry => movies.ContainsKey(entry.Score.MovieId))
                .Select(entry => Describe(entry.Score, entry.Source, movies))
                .ToList());
        }

        private async Task<Dictionary<int, MovieFeatures>> LoadFeaturesAsync(
            List<PopularityCandidate> candidates,
            List<UserMovieSignal> ownSignals)
        {
            var movieIds = candidates
                .Select(candidate => candidate.MovieId)
                .Concat(ownSignals.Where(signal => signal.Affinity > 0).Select(signal => signal.MovieId))
                .Distinct()
                .ToList();

            var features = await _signalService.GetMovieFeaturesAsync(movieIds);

            return features.ToDictionary(movie => movie.MovieId);
        }

        private async Task<Dictionary<int, MovieResponse>> LoadMovieResponsesAsync(
            IEnumerable<RecommendationScore> ranked)
        {
            var movieIds = ranked
                .SelectMany(score => score.ContentSeedMovieId is int seedId
                    ? new[] { score.MovieId, seedId }
                    : [score.MovieId])
                .Distinct()
                .ToList();

            var entities = await _context.Movies
                .Where(movie => movieIds.Contains(movie.Id))
                .Include(movie => movie.Country)
                .Include(movie => movie.Language)
                .Include(movie => movie.Genres)
                .Include(movie => movie.Studios)
                .ThenInclude(studio => studio.Studio)
                .Include(movie => movie.Reviews)
                .AsSplitQuery()
                .ToListAsync();

            var responses = new Dictionary<int, MovieResponse>();

            foreach (var entity in entities)
            {
                var response = _mapper.Map<MovieResponse>(entity);

                _imageUrlResolver.Resolve(response);

                responses[entity.Id] = response;
            }

            return responses;
        }

        private static MovieRecommendationResponse Describe(
            RecommendationScore score,
            RecommendationSource source,
            IReadOnlyDictionary<int, MovieResponse> movies)
        {
            var recommendation = new MovieRecommendationResponse
            {
                RecommendedMovieId = score.MovieId,
                RecommendedMovie = movies[score.MovieId],
                Score = score.Score,
                Source = source
            };

            if (source == RecommendationSource.Popular)
            {
                recommendation.Reason = PopularReason;
                return recommendation;
            }

            // Whichever half of the blend contributed more is the half that gets to explain itself.
            var collaborative = score.CollaborativeScore * HybridRecommender.MaxCollaborativeWeight;

            if (collaborative > score.ContentScore)
            {
                recommendation.Reason = NeighbourReason;
                return recommendation;
            }

            if (score.ContentSeedMovieId is int seedId && movies.TryGetValue(seedId, out var seed))
            {
                recommendation.MovieId = seedId;
                recommendation.Movie = seed;
                recommendation.Reason = $"Because you liked {seed.Title}";
                return recommendation;
            }

            recommendation.Reason = ProfileReason;

            return recommendation;
        }

        private static PageResult<MovieRecommendationResponse> Page(List<MovieRecommendationResponse> items)
            => new() { Items = items, TotalCount = items.Count };
    }
}
