namespace Flix.Services.Recommendations
{
    public sealed record MovieAttributes(
        int MovieId,
        IReadOnlyCollection<int> GenreIds,
        IReadOnlyCollection<int> DirectorIds,
        IReadOnlyCollection<int> ActorIds,
        IReadOnlyCollection<int> StudioIds,
        int? CountryId,
        int? LanguageId,
        int? ReleaseYear);

    // What the content-based side compares: a movie reduced to the attributes the catalog actually
    // carries, weighted by how much each says about taste. Genre and director separate films far
    // better than the country they were shot in, so they are worth more before normalization.
    public sealed record MovieFeatures(int MovieId, TokenVector Vector)
    {
        private const float GenreWeight = 1.0f;
        private const float DirectorWeight = 0.9f;
        private const float ActorWeight = 0.5f;
        private const float StudioWeight = 0.4f;
        private const float DecadeWeight = 0.3f;
        private const float CountryWeight = 0.25f;
        private const float LanguageWeight = 0.25f;

        // A full cast of extras is noise, and the billing order is what says who carried the film.
        public const int BilledActorLimit = 8;

        public static MovieFeatures From(MovieAttributes attributes)
        {
            var tokens = new Dictionary<string, float>();

            foreach (var genreId in attributes.GenreIds)
                tokens[$"genre:{genreId}"] = GenreWeight;

            foreach (var directorId in attributes.DirectorIds)
                tokens[$"director:{directorId}"] = DirectorWeight;

            foreach (var actorId in attributes.ActorIds.Take(BilledActorLimit))
                tokens[$"actor:{actorId}"] = ActorWeight;

            foreach (var studioId in attributes.StudioIds)
                tokens[$"studio:{studioId}"] = StudioWeight;

            if (attributes.ReleaseYear is int year)
                tokens[$"decade:{year / 10}"] = DecadeWeight;

            if (attributes.CountryId is int countryId)
                tokens[$"country:{countryId}"] = CountryWeight;

            if (attributes.LanguageId is int languageId)
                tokens[$"language:{languageId}"] = LanguageWeight;

            return new MovieFeatures(attributes.MovieId, TokenVector.Normalized(tokens));
        }

        public float Similarity(MovieFeatures other) => Vector.Dot(other.Vector);
    }
}
