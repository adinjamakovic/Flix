using Flix.Services.Recommendations;
using Xunit;

namespace Flix.Services.Tests
{
    public class HybridRecommenderTests
    {
        [Fact]
        public void ContentBasedRankingPutsAMovieSharingGenreAndDirectorAboveAnUnrelatedOne()
        {
            var features = Features(
                Movie(1, genres: [10], directors: [100], countryId: 1, languageId: 1, releaseYear: 2012),
                Movie(2, genres: [10], directors: [100], countryId: 1, languageId: 1, releaseYear: 2015),
                Movie(3, genres: [20], directors: [200], countryId: 2, languageId: 1, releaseYear: 1971));

            var signals = new RecommendationSignalBuilder()
                .AddReview(userId: 1, movieId: 1, rating: 5.0m, isLiked: true)
                .Build();

            var ranked = HybridRecommender.Recommend(
                userId: 1,
                signals,
                features,
                candidateMovieIds: [2, 3],
                take: 10);

            Assert.Equal(new[] { 2, 3 }, ranked.Select(recommendation => recommendation.MovieId).ToArray());
            Assert.True(ScoreOf(ranked, 2) > ScoreOf(ranked, 3));
            Assert.Equal(1, ranked.First().ContentSeedMovieId!.Value);
        }

        // No shared attributes anywhere, so nothing but the neighbourhood can order these two.
        [Fact]
        public void CollaborativeRankingPutsACloseNeighboursPickAboveADistantNeighboursPick()
        {
            var signals = new RecommendationSignalBuilder()
                .AddReview(userId: 1, movieId: 1, rating: 5.0m, isLiked: false)
                .AddReview(userId: 1, movieId: 2, rating: 5.0m, isLiked: false)
                .AddReview(userId: 2, movieId: 1, rating: 5.0m, isLiked: false)
                .AddReview(userId: 2, movieId: 2, rating: 5.0m, isLiked: false)
                .AddReview(userId: 2, movieId: 3, rating: 5.0m, isLiked: false)
                .AddReview(userId: 3, movieId: 1, rating: 5.0m, isLiked: false)
                .AddReview(userId: 3, movieId: 2, rating: 5.0m, isLiked: false)
                .AddReview(userId: 3, movieId: 3, rating: 5.0m, isLiked: false)
                .AddReview(userId: 4, movieId: 1, rating: 5.0m, isLiked: false)
                .AddReview(userId: 4, movieId: 2, rating: 5.0m, isLiked: false)
                .AddReview(userId: 4, movieId: 4, rating: 5.0m, isLiked: false)
                .AddReview(userId: 4, movieId: 6, rating: 5.0m, isLiked: false)
                .AddReview(userId: 4, movieId: 7, rating: 5.0m, isLiked: false)
                .AddReview(userId: 4, movieId: 8, rating: 5.0m, isLiked: false)
                .Build();

            var ranked = HybridRecommender.Recommend(
                userId: 1,
                signals,
                features: new Dictionary<int, MovieFeatures>(),
                candidateMovieIds: [3, 4],
                take: 10);

            Assert.Equal(new[] { 3, 4 }, ranked.Select(recommendation => recommendation.MovieId).ToArray());
            Assert.True(ScoreOf(ranked, 3) > ScoreOf(ranked, 4));
        }

        [Fact]
        public void AUserSharingASingleMovieIsNotANeighbour()
        {
            var signals = new RecommendationSignalBuilder()
                .AddReview(userId: 1, movieId: 1, rating: 5.0m, isLiked: false)
                .AddReview(userId: 2, movieId: 1, rating: 5.0m, isLiked: false)
                .AddReview(userId: 2, movieId: 3, rating: 5.0m, isLiked: false)
                .Build();

            var ranked = HybridRecommender.Recommend(
                userId: 1,
                signals,
                features: new Dictionary<int, MovieFeatures>(),
                candidateMovieIds: [3],
                take: 10);

            Assert.Empty(ranked);
        }

        [Fact]
        public void AUserWithNoSignalsGetsNothingFromTheHybrid()
        {
            var signals = new RecommendationSignalBuilder()
                .AddReview(userId: 2, movieId: 1, rating: 5.0m, isLiked: false)
                .Build();

            var ranked = HybridRecommender.Recommend(
                userId: 99,
                signals,
                features: Features(Movie(1, genres: [10])),
                candidateMovieIds: [1],
                take: 10);

            Assert.Empty(ranked);
        }

        [Fact]
        public void PopularityRankingPrefersManyLikesOverASingleStrongOne()
        {
            var signals = new RecommendationSignalBuilder()
                .AddReview(userId: 1, movieId: 1, rating: 5.0m, isLiked: false)
                .AddReview(userId: 2, movieId: 1, rating: 5.0m, isLiked: false)
                .AddReview(userId: 3, movieId: 1, rating: 5.0m, isLiked: false)
                .AddReview(userId: 4, movieId: 1, rating: 5.0m, isLiked: false)
                .AddReview(userId: 5, movieId: 2, rating: 5.0m, isLiked: false)
                .Build();

            var ranked = HybridRecommender.RankByPopularity(
                signals,
                [new PopularityCandidate(2, Views: 0), new PopularityCandidate(1, Views: 0)],
                take: 10);

            Assert.Equal(new[] { 1, 2 }, ranked.Select(recommendation => recommendation.MovieId).ToArray());
        }

        private static float ScoreOf(IEnumerable<RecommendationScore> ranked, int movieId)
            => ranked.Single(recommendation => recommendation.MovieId == movieId).Score;

        private static Dictionary<int, MovieFeatures> Features(params MovieFeatures[] movies)
            => movies.ToDictionary(movie => movie.MovieId);

        private static MovieFeatures Movie(
            int movieId,
            int[]? genres = null,
            int[]? directors = null,
            int[]? actors = null,
            int[]? studios = null,
            int? countryId = null,
            int? languageId = null,
            int? releaseYear = null)
            => MovieFeatures.From(new MovieAttributes(
                movieId,
                genres ?? [],
                directors ?? [],
                actors ?? [],
                studios ?? [],
                countryId,
                languageId,
                releaseYear));
    }
}
