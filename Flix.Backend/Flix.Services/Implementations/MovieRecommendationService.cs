using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
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
            var positiveSignals = await _context.Reviews
                .Where(r => r.IsLiked || (r.Rating != null && r.Rating >= MinimumPositiveRating))
                .Select(r => new { r.UserId, r.MovieId })
                .Distinct()
                .ToListAsync();

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

        public async Task<List<MovieRecommendationResponse>> GetRecommendationsForMovieAsync(MovieRecommendationSearchObject search)
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

            return recommendations;
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
