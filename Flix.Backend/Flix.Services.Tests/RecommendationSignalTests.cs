using Flix.Services.Recommendations;
using Xunit;

namespace Flix.Services.Tests
{
    public class RecommendationSignalTests
    {
        [Fact]
        public void EachSignalCarriesTheStrengthTheSpecificationGivesIt()
        {
            var signals = new RecommendationSignalBuilder()
                .AddReview(userId: 1, movieId: 1, rating: 4.5m, isLiked: false)
                .AddReview(userId: 1, movieId: 2, rating: null, isLiked: true)
                .AddWatchlistEntry(userId: 1, movieId: 3)
                .AddWatch(userId: 1, movieId: 4)
                .Build();

            Assert.Equal(RecommendationSignalWeights.Rated, AffinityOf(signals, 1));
            Assert.Equal(RecommendationSignalWeights.Liked, AffinityOf(signals, 2));
            Assert.Equal(RecommendationSignalWeights.Watchlisted, AffinityOf(signals, 3));
            Assert.Equal(RecommendationSignalWeights.Watched, AffinityOf(signals, 4));
        }

        [Fact]
        public void ARatingBelowTheThresholdIsWatchedWithoutAffinity()
        {
            var signals = new RecommendationSignalBuilder()
                .AddReview(userId: 1, movieId: 1, rating: 1.0m, isLiked: false)
                .AddWatch(userId: 1, movieId: 1)
                .Build();

            var signal = Assert.Single(signals);

            Assert.Equal(0f, signal.Affinity);
            Assert.True(signal.IsWatched);
        }

        [Fact]
        public void AWatchlistEntryIsAffinityWithoutHavingBeenWatched()
        {
            var signals = new RecommendationSignalBuilder()
                .AddWatchlistEntry(userId: 1, movieId: 1)
                .Build();

            var signal = Assert.Single(signals);

            Assert.Equal(RecommendationSignalWeights.Watchlisted, signal.Affinity);
            Assert.False(signal.IsWatched);
        }

        [Fact]
        public void SignalsForOnePairDoNotAddUp()
        {
            var signals = new RecommendationSignalBuilder()
                .AddReview(userId: 1, movieId: 1, rating: 5.0m, isLiked: true)
                .AddWatchlistEntry(userId: 1, movieId: 1)
                .AddWatch(userId: 1, movieId: 1)
                .Build();

            Assert.Equal(RecommendationSignalWeights.Rated, Assert.Single(signals).Affinity);
        }

        // A movie rated below the threshold carries no affinity, so it never reaches the profile or
        // the neighbourhood - it only ever excludes itself from the candidates.
        [Fact]
        public void APoorlyRatedMovieContributesNothingToTheProfile()
        {
            var signals = new RecommendationSignalBuilder()
                .AddReview(userId: 1, movieId: 10, rating: 5.0m, isLiked: false)
                .AddReview(userId: 1, movieId: 20, rating: 1.0m, isLiked: false)
                .Build();

            Assert.Single(signals.Where(signal => signal.Affinity > 0));
        }

        private static float AffinityOf(IEnumerable<UserMovieSignal> signals, int movieId)
            => signals.Single(signal => signal.MovieId == movieId).Affinity;
    }
}
