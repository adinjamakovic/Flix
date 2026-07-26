namespace Flix.Model.Responses
{
    public class MovieResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? TrailerUrl { get; set; }
        public DateTime? ReleaseDate { get; set; }
        public int? DurationMinutes { get; set; }
        public int Views { get; set; }
        public bool IsEnabled { get; set; }

        public int? CountryId { get; set; }
        public string? CountryName { get; set; }

        public int? LanguageId { get; set; }
        public string? LanguageName { get; set; }

        public List<GenreResponse> Genres { get; set; } = new List<GenreResponse>();
    }
}
