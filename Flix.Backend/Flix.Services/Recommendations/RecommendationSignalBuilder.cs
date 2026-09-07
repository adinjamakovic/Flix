namespace Flix.Services.Recommendations
{
    public sealed class RecommendationSignalBuilder
    {
        private sealed class Accumulator
        {
            public float Affinity;
            public bool IsWatched;
            public bool IsRated;
        }

        private readonly Dictionary<(int UserId, int MovieId), Accumulator> _pairs = [];

        public RecommendationSignalBuilder AddReview(int userId, int movieId, decimal? rating, bool isLiked)
        {
            var pair = PairOf(userId, movieId);

            pair.IsWatched = true;

            if (rating != null)
            {
                pair.IsRated = true;

                if (rating >= RecommendationSignalWeights.MinimumPositiveRating)
                    Raise(pair, RecommendationSignalWeights.Rated);
            }

            if (isLiked)
                Raise(pair, RecommendationSignalWeights.Liked);

            return this;
        }

        public RecommendationSignalBuilder AddWatchlistEntry(int userId, int movieId)
        {
            Raise(PairOf(userId, movieId), RecommendationSignalWeights.Watchlisted);

            return this;
        }

        public RecommendationSignalBuilder AddWatch(int userId, int movieId)
        {
            PairOf(userId, movieId).IsWatched = true;

            return this;
        }

        // Ordered so that everything downstream - neighbour ties, seed ties, the training pairs -
        // comes out the same way on every run.
        public IReadOnlyList<UserMovieSignal> Build()
            => _pairs
                .OrderBy(pair => pair.Key.UserId)
                .ThenBy(pair => pair.Key.MovieId)
                .Select(pair => new UserMovieSignal(
                    pair.Key.UserId,
                    pair.Key.MovieId,
                    AffinityOf(pair.Value),
                    pair.Value.IsWatched))
                .ToList();

        // The weakest signal is "logged as watched *without* a rating". Once a rating exists it has
        // already said everything this one would, in either direction - which is what leaves a
        // 1-star review watched with no affinity at all.
        private static float AffinityOf(Accumulator pair)
            => pair.IsWatched && !pair.IsRated
                ? Math.Max(pair.Affinity, RecommendationSignalWeights.Watched)
                : pair.Affinity;

        private Accumulator PairOf(int userId, int movieId)
        {
            var key = (userId, movieId);

            if (!_pairs.TryGetValue(key, out var pair))
                _pairs[key] = pair = new Accumulator();

            return pair;
        }

        private static void Raise(Accumulator pair, float affinity)
            => pair.Affinity = Math.Max(pair.Affinity, affinity);
    }
}
