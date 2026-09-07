namespace Flix.Services.Recommendations
{
    public static class RecommendationSignalWeights
    {
        public const decimal MinimumPositiveRating = 3.0m;

        public const float Rated = 1.0f;
        public const float Liked = 0.6f;
        public const float Watchlisted = 0.6f;
        public const float Watched = 0.25f;
    }
}
