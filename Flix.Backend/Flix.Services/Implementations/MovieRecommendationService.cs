using Flix.Model.Enums;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Enums;
using Flix.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;

namespace Flix.Services.Implementations
{
    public class MovieRecommendationService : IMovieRecommendationService
    {
        private const decimal MinimumPositiveRating = 3.0m;
        private const int RecommendationsPerMovie = 10;
        private const int SeedMoviesPerUser = 3;
        private const int RecommendationsPerSeed = 6;
        private const int PopularFallbackCount = 10;

        private readonly FlixDbContext _context;
        protected readonly MapsterMapper.IMapper _mapper;
        private readonly IResponseImageUrlResolver _imageUrlResolver;
        public MovieRecommendationService(
            FlixDbContext context,
            MapsterMapper.IMapper mapper,
            IResponseImageUrlResolver imageUrlResolver
        )
        {
            _context = context;
            _mapper = mapper;
            _imageUrlResolver = imageUrlResolver;
        }

        private async Task<List<MovieEntry>> BuildTrainingData(IReadOnlyDictionary<int, uint> matrixIndexByMovieId)
        {
            var reviewSignals = await _context.Reviews
                .Where(r => r.IsLiked ||
                    (r.Rating != null && r.Rating >= MinimumPositiveRating))
                .Select(r => new { r.UserId, r.MovieId })
                .Distinct()
                .ToListAsync();

            var watchlistSignals = await _context.MovieListItems
                .Where(i => i.MovieList.Type == ListType.Watchlist)
                .Select(i => new { i.MovieList.UserId, i.MovieId })
                .Distinct()
                .ToListAsync();

            var positiveSignals = reviewSignals.Concat(watchlistSignals);

            var moviesPerUser = positiveSignals
                .GroupBy(s => s.UserId)
                .Select(g => g.Select(s => s.MovieId).Distinct().OrderBy(id => id).ToList())
                .Where(movies => movies.Count > 1);

            var data = new List<MovieEntry>();

            foreach (var movies in moviesPerUser)
            {
                for (var i = 0; i < movies.Count; i++)
                {
                    for (var j = i + 1; j < movies.Count; j++)
                    {
                        data.Add(new MovieEntry
                        {
                            MovieId = matrixIndexByMovieId[movies[i]],
                            CoReviewMovieId = matrixIndexByMovieId[movies[j]],
                        });
                        data.Add(new MovieEntry
                        {
                            MovieId = matrixIndexByMovieId[movies[j]],
                            CoReviewMovieId = matrixIndexByMovieId[movies[i]],
                        });
                    }
                }
            }

            return data;
        }

        // The trainer indexes its matrix by position, so movie ids have to be mapped
        // onto a dense 0..n-1 range. Feeding raw ids in would put any id at or above
        // the key column's size out of range, and out-of-range keys score NaN, which
        // SQL Server then rejects as an invalid value for `real`.
        private static SchemaDefinition BuildSchema(int movieCount)
        {
            var schema = SchemaDefinition.Create(typeof(MovieEntry));
            schema[nameof(MovieEntry.MovieId)].ColumnType = new KeyDataViewType(typeof(uint), movieCount);
            schema[nameof(MovieEntry.CoReviewMovieId)].ColumnType = new KeyDataViewType(typeof(uint), movieCount);
            return schema;
        }

        public List<MovieRecommendation> RecommendSingleMovie(
            Movie movie,
            List<Movie> allMovies,
            IReadOnlyDictionary<int, uint> matrixIndexByMovieId,
            PredictionEngine<MovieEntry, CoReviewPrediction> predictionEngine)
        {
            var predictionResult = new List<(Movie Movie, float Score)>();

            foreach (var recommendedMovie in allMovies)
            {
                if (recommendedMovie.Id == movie.Id)
                    continue;

                var prediction = predictionEngine.Predict(new MovieEntry
                {
                    MovieId = matrixIndexByMovieId[movie.Id],
                    CoReviewMovieId = matrixIndexByMovieId[recommendedMovie.Id]
                });

                if (!float.IsFinite(prediction.Score))
                    continue;

                predictionResult.Add((recommendedMovie, prediction.Score));
            }

            return predictionResult
                .OrderByDescending(x => x.Score)
                .Take(RecommendationsPerMovie)
                .Select(x => new MovieRecommendation
                {
                    MovieId = movie.Id,
                    RecommendedMovieId = x.Movie.Id,
                    Score = x.Score
                })
                .ToList();
        }

        public async Task SaveRecommendationsForAllMovies(
            List<Movie> movies,
            IReadOnlyDictionary<int, uint> matrixIndexByMovieId,
            PredictionEngine<MovieEntry, CoReviewPrediction> predictionEngine)
        {
            foreach (var movie in movies)
            {
                var recommendedEntities = RecommendSingleMovie(movie, movies, matrixIndexByMovieId, predictionEngine);
                await _context.MovieRecommendations.AddRangeAsync(recommendedEntities);
            }
            await _context.SaveChangesAsync();
        }

        public async Task GenerateRecommendationAsync()
        {
            var movies = await _context.Movies.OrderBy(m => m.Id).ToListAsync();

            if (movies.Count < 2)
                return;

            var matrixIndexByMovieId = movies
                .Select((movie, index) => (movie.Id, Index: (uint)index))
                .ToDictionary(x => x.Id, x => x.Index);

            var data = await BuildTrainingData(matrixIndexByMovieId);

            if (data.Count == 0)
                return;

            var mlContext = new MLContext();
            var schema = BuildSchema(movies.Count);

            var trainingData = mlContext.Data.LoadFromEnumerable(data, schema);

            var options = new MatrixFactorizationTrainer.Options
            {
                MatrixColumnIndexColumnName = nameof(MovieEntry.MovieId),
                MatrixRowIndexColumnName = nameof(MovieEntry.CoReviewMovieId),
                LabelColumnName = "Label",
                LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                Alpha = 0.01,
                Lambda = 0.025,
                NumberOfIterations = 100,
                C = 0.00001
            };

            var estimator = mlContext.Recommendation().Trainers.MatrixFactorization(options);

            var model = estimator.Fit(trainingData);

            using var predictionEngine = mlContext.Model
                .CreatePredictionEngine<MovieEntry, CoReviewPrediction>(model, inputSchemaDefinition: schema);

            // Every run produces a full set for the whole catalog, so the previous run's rows have to
            // go - otherwise they pile up and the reads below hand back the same movie several times.
            // Both statements share a transaction so a failed write cannot leave the table empty.
            await using var transaction = await _context.Database.BeginTransactionAsync();

            await DeleteOldRecommendations();
            await SaveRecommendationsForAllMovies(movies, matrixIndexByMovieId, predictionEngine);

            await transaction.CommitAsync();
        }
        public async Task DeleteOldRecommendations()
        {
            await _context.MovieRecommendations.ExecuteDeleteAsync();
        }

        public async Task<PageResult<MovieRecommendationResponse>> GetRecommendationsForMovieAsync(MovieRecommendationSearchObject search)
        {
            var recommendationEntities = await _context.MovieRecommendations
                .Include(x=>x.RecommendedMovie)
                .Where(x=>x.MovieId == search.MovieId)
                .OrderByDescending(x=>x.Score)
                .Take(search.NumberOfRecommendations)
                .ToListAsync();

            var recommendations = recommendationEntities.Select(x => _mapper.Map<MovieRecommendationResponse>(x)).ToList();

            // The poster and header columns hold blob paths, which are useless to a client on their
            // own, so every movie leaving here goes through the resolver the same way MovieService does.
            foreach (var recommendation in recommendations)
            {
                _imageUrlResolver.Resolve(recommendation.Movie);
                _imageUrlResolver.Resolve(recommendation.RecommendedMovie);
            }

            return new PageResult<MovieRecommendationResponse>
            {
                Items = recommendations,
                TotalCount = recommendations.Count
            };
        }

        public async Task<PageResult<MovieRecommendationResponse>> GetRecommendationsForUserAsync(int userId)
        {
            var excludedMovieIds = await GetMoviesAlreadySeenByUser(userId);

            // The seeds are the user's most recently reviewed movies that they actually liked -
            // rated at least MinimumPositiveRating, or liked outright. Grouping first keeps a
            // rewatched movie from taking two of the three slots.
            var seedMovieIds = await _context.Reviews
                .Where(x => x.UserId == userId &&
                (
                    (x.Rating != null && x.Rating >= MinimumPositiveRating)
                    || x.IsLiked
                ))
                .GroupBy(x => x.MovieId)
                .OrderByDescending(g => g.Max(x => x.CreatedAt))
                .Select(g => g.Key)
                .Take(SeedMoviesPerUser)
                .ToListAsync();

            if (seedMovieIds.Count == 0)
                return await GetPopularRecommendationsAsync(excludedMovieIds);

            var recommendations = new List<MovieRecommendationResponse>();
            var addedMovieIds = new HashSet<int>();

            foreach (var seedMovieId in seedMovieIds)
            {
                // Everything stored for the seed rather than the handful that survive: the
                // exclusions knock out most of a seed's set, because the movies sitting closest
                // to one the user liked are the ones they are most likely to have seen already.
                var set = await GetRecommendationsForMovieAsync(new MovieRecommendationSearchObject
                {
                    MovieId = seedMovieId,
                    NumberOfRecommendations = RecommendationsPerMovie
                });

                var keptForSeed = 0;

                foreach (var recommendation in set.Items)
                {
                    if (keptForSeed == RecommendationsPerSeed)
                        break;

                    if (excludedMovieIds.Contains(recommendation.RecommendedMovieId))
                        continue;

                    // Two seeds routinely point at the same movie, and the responses are separate
                    // objects, so the de-duplication has to go by recommended movie id.
                    if (!addedMovieIds.Add(recommendation.RecommendedMovieId))
                        continue;

                    recommendations.Add(recommendation);
                    keptForSeed++;
                }
            }

            if (recommendations.Count == 0)
                return await GetPopularRecommendationsAsync(excludedMovieIds);

            return new PageResult<MovieRecommendationResponse>
            {
                Items = recommendations,
                TotalCount = recommendations.Count
            };
        }

        private async Task<PageResult<MovieRecommendationResponse>> GetPopularRecommendationsAsync(HashSet<int> excludedMovieIds)
        {
            var reviewSignals = _context.Reviews
                .Where(r => r.Movie.IsEnabled && !excludedMovieIds.Contains(r.MovieId))
                .Select(r => new { r.UserId, r.MovieId });

            var watchlistSignals = _context.MovieListItems
                .Where(i => i.MovieList.Type == ListType.Watchlist
                    && i.Movie.IsEnabled
                    && !excludedMovieIds.Contains(i.MovieId))
                .Select(i => new { i.MovieList.UserId, i.MovieId });

            var rankedMovieIds = await reviewSignals
                .Concat(watchlistSignals)
                .Distinct()
                .GroupBy(s => s.MovieId)
                .Select(g => new { MovieId = g.Key, UserCount = g.Count() })
                .OrderByDescending(x => x.UserCount)
                .ThenBy(x => x.MovieId)
                .Take(PopularFallbackCount)
                .Select(x => x.MovieId)
                .ToListAsync();

            // A movie nobody has touched yet has no signal to rank on, but it is still unseen and
            // still worth offering - and to a user who has been through the rest of the catalog it
            // is the only thing left. 
            if (rankedMovieIds.Count < PopularFallbackCount)
            {
                var untouchedMovieIds = await _context.Movies
                    .Where(m => m.IsEnabled
                        && !excludedMovieIds.Contains(m.Id)
                        && !rankedMovieIds.Contains(m.Id))
                    .OrderByDescending(m => m.Views)
                    .ThenBy(m => m.Id)
                    .Select(m => m.Id)
                    .Take(PopularFallbackCount - rankedMovieIds.Count)
                    .ToListAsync();

                rankedMovieIds.AddRange(untouchedMovieIds);
            }

            if (rankedMovieIds.Count == 0)
                return new PageResult<MovieRecommendationResponse> { Items = [], TotalCount = 0 };

            var moviesById = await _context.Movies
                .Where(m => rankedMovieIds.Contains(m.Id))
                .ToDictionaryAsync(m => m.Id);

            var popular = rankedMovieIds
                .Where(moviesById.ContainsKey)
                .Select(movieId =>
                {
                    var movie = _mapper.Map<MovieResponse>(moviesById[movieId]);

                    _imageUrlResolver.Resolve(movie);

                    return new MovieRecommendationResponse
                    {
                        RecommendedMovieId = movieId,
                        RecommendedMovie = movie,
                        Source = RecommendationSource.Popular
                    };
                })
                .ToList();

            return new PageResult<MovieRecommendationResponse>
            {
                Items = popular,
                TotalCount = popular.Count
            };
        }

        // A recommendation is only useful if it is a discovery, so anything the user has already
        // reviewed, put on their watchlist or marked watched is off the table - the seeds
        // included, since the recommender links co-reviewed movies in both directions.
        private async Task<HashSet<int>> GetMoviesAlreadySeenByUser(int userId)
        {
            var reviewed = _context.Reviews
                .Where(x => x.UserId == userId)
                .Select(x => x.MovieId);

            var watchlisted = _context.MovieListItems
                .Where(x => x.MovieList.UserId == userId && x.MovieList.Type == ListType.Watchlist)
                .Select(x => x.MovieId);

            var watched = _context.Activities
                .Where(x => x.UserId == userId && x.Type == ActivityType.WatchedMovie && x.MovieId != null)
                .Select(x => x.MovieId!.Value);

            var movieIds = await reviewed
                .Union(watchlisted)
                .Union(watched)
                .ToListAsync();

            return movieIds.ToHashSet();
        }
    }

    
}

public class CoReviewPrediction
{
    public float Score {get; set;}
}

// The key column sizes are set at load time from the catalog size, so no KeyType
// attribute here — see MovieRecommendationService.BuildSchema.
public class MovieEntry
{
    public uint MovieId {get; set;}
    public uint CoReviewMovieId {get; set;}
    public float Label {get; set;}
}
