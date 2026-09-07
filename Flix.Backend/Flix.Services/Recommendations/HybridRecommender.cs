namespace Flix.Services.Recommendations
{
    public sealed record RecommendationScore(
        int MovieId,
        float Score,
        float ContentScore,
        float CollaborativeScore,
        int? ContentSeedMovieId);

    public sealed record PopularityCandidate(int MovieId, int Views);
    public static class HybridRecommender
    {
        public const float MaxCollaborativeWeight = 0.6f;

        private const int NeighboursForFullWeight = 5;
        private const int MaxNeighbours = 30;
        private const int MinimumSharedMovies = 2;
        private const float NeighbourShrinkage = 1.0f;
        private const float PopularityShrinkage = 2.0f;

        public static IReadOnlyList<RecommendationScore> Recommend(
            int userId,
            IReadOnlyCollection<UserMovieSignal> signals,
            IReadOnlyDictionary<int, MovieFeatures> features,
            IReadOnlyCollection<int> candidateMovieIds,
            int take)
        {
            var profileSignals = signals
                .Where(signal => signal.UserId == userId && signal.Affinity > 0)
                .OrderBy(signal => signal.MovieId)
                .ToList();

            if (profileSignals.Count == 0 || candidateMovieIds.Count == 0)
                return [];

            var profile = BuildProfile(profileSignals, features);
            var neighbours = FindNeighbours(userId, signals);
            var neighbourInterest = ScoreNeighbourInterest(neighbours, signals);

            // With no neighbours the list is purely content-based; the collaborative half only takes
            // over once there are enough of them for their agreement to mean anything.
            var collaborativeWeight = MaxCollaborativeWeight
                * Math.Min(1f, neighbours.Count / (float)NeighboursForFullWeight);

            var scored = new List<RecommendationScore>();

            foreach (var movieId in candidateMovieIds.OrderBy(id => id))
            {
                features.TryGetValue(movieId, out var candidate);

                var content = candidate is null ? 0f : profile.Dot(candidate.Vector);

                var collaborative = neighbourInterest.TryGetValue(movieId, out var interest)
                    ? interest.Weighted / (interest.Similarity + NeighbourShrinkage)
                    : 0f;

                var score = collaborativeWeight * collaborative + (1 - collaborativeWeight) * content;

                if (score <= 0)
                    continue;

                scored.Add(new RecommendationScore(
                    movieId,
                    score,
                    content,
                    collaborative,
                    SeedFor(candidate, profileSignals, features)));
            }

            return scored
                .OrderByDescending(recommendation => recommendation.Score)
                .ThenBy(recommendation => recommendation.MovieId)
                .Take(take)
                .ToList();
        }

        // What a user with nothing to learn from gets. Shrunk rather than a plain average so a
        // single five-star review cannot outrank a movie fifty people liked.
        public static IReadOnlyList<RecommendationScore> RankByPopularity(
            IReadOnlyCollection<UserMovieSignal> signals,
            IReadOnlyCollection<PopularityCandidate> candidates,
            int take)
        {
            var interest = signals
                .Where(signal => signal.Affinity > 0)
                .GroupBy(signal => signal.MovieId)
                .ToDictionary(
                    group => group.Key,
                    group => group.Sum(signal => signal.Affinity) / (group.Count() + PopularityShrinkage));

            return candidates
                .Select(candidate => new
                {
                    Candidate = candidate,
                    Score = interest.GetValueOrDefault(candidate.MovieId)
                })
                .OrderByDescending(ranked => ranked.Score)
                .ThenByDescending(ranked => ranked.Candidate.Views)
                .ThenBy(ranked => ranked.Candidate.MovieId)
                .Take(take)
                .Select(ranked => new RecommendationScore(ranked.Candidate.MovieId, ranked.Score, 0f, 0f, null))
                .ToList();
        }

        private static TokenVector BuildProfile(
            IEnumerable<UserMovieSignal> profileSignals,
            IReadOnlyDictionary<int, MovieFeatures> features)
        {
            var weights = new Dictionary<string, float>();

            foreach (var signal in profileSignals)
            {
                if (!features.TryGetValue(signal.MovieId, out var movie))
                    continue;

                foreach (var (token, weight) in movie.Vector.Weights)
                    weights[token] = weights.GetValueOrDefault(token) + signal.Affinity * weight;
            }

            return TokenVector.Normalized(weights);
        }

        private static List<(int UserId, float Similarity)> FindNeighbours(
            int userId,
            IReadOnlyCollection<UserMovieSignal> signals)
        {
            var affinityByUser = AffinityByUser(signals);

            if (!affinityByUser.TryGetValue(userId, out var target))
                return [];

            var targetNorm = Norm(target.Values);
            var neighbours = new List<(int UserId, float Similarity)>();

            foreach (var (otherId, other) in affinityByUser)
            {
                if (otherId == userId)
                    continue;

                var dot = 0f;
                var shared = 0;

                foreach (var (movieId, affinity) in target)
                {
                    if (!other.TryGetValue(movieId, out var otherAffinity))
                        continue;

                    dot += affinity * otherAffinity;
                    shared++;
                }

                // One movie in common is a coincidence, not a shared taste.
                if (shared < MinimumSharedMovies || dot <= 0)
                    continue;

                neighbours.Add((otherId, dot / (targetNorm * Norm(other.Values))));
            }

            return neighbours
                .OrderByDescending(neighbour => neighbour.Similarity)
                .ThenBy(neighbour => neighbour.UserId)
                .Take(MaxNeighbours)
                .ToList();
        }

        private static Dictionary<int, (float Weighted, float Similarity)> ScoreNeighbourInterest(
            List<(int UserId, float Similarity)> neighbours,
            IReadOnlyCollection<UserMovieSignal> signals)
        {
            var similarityByUser = neighbours.ToDictionary(
                neighbour => neighbour.UserId,
                neighbour => neighbour.Similarity);

            var interest = new Dictionary<int, (float Weighted, float Similarity)>();

            foreach (var signal in signals)
            {
                if (signal.Affinity <= 0 || !similarityByUser.TryGetValue(signal.UserId, out var similarity))
                    continue;

                var running = interest.GetValueOrDefault(signal.MovieId);

                interest[signal.MovieId] = (
                    running.Weighted + similarity * signal.Affinity,
                    running.Similarity + similarity);
            }

            return interest;
        }

        // Which of the user's own movies best explains the candidate, so the list can say why.
        // Strictly greater keeps the lowest movie id on a tie, and the caller hands the signals in
        // id order.
        private static int? SeedFor(
            MovieFeatures? candidate,
            IEnumerable<UserMovieSignal> profileSignals,
            IReadOnlyDictionary<int, MovieFeatures> features)
        {
            if (candidate is null)
                return null;

            int? seedMovieId = null;
            var best = 0f;

            foreach (var signal in profileSignals)
            {
                if (!features.TryGetValue(signal.MovieId, out var movie))
                    continue;

                var overlap = signal.Affinity * movie.Similarity(candidate);

                if (overlap <= best)
                    continue;

                best = overlap;
                seedMovieId = signal.MovieId;
            }

            return seedMovieId;
        }

        private static Dictionary<int, Dictionary<int, float>> AffinityByUser(
            IReadOnlyCollection<UserMovieSignal> signals)
            => signals
                .Where(signal => signal.Affinity > 0)
                .GroupBy(signal => signal.UserId)
                .ToDictionary(
                    group => group.Key,
                    group => group.ToDictionary(signal => signal.MovieId, signal => signal.Affinity));

        private static float Norm(IEnumerable<float> values)
            => MathF.Sqrt(values.Sum(value => value * value));
    }
}
