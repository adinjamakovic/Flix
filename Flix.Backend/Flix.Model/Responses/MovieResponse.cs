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
        public string? Poster { get; set; }
        public string? HeaderImage { get; set; }
        public bool IsEnabled { get; set; }
        public decimal? Rating { get; set; }
        public int ReviewCount { get; set; }
        public CountryResponse? Country { get; set; }
        public LanguageResponse? Language { get; set; }
        public List<CastMemberResponse> Directors { get; set; } = new List<CastMemberResponse>();
        public List<MovieCreditResponse> Cast { get; set; } = new List<MovieCreditResponse>();
        public List<GenreResponse> Genres { get; set; } = new List<GenreResponse>();
        public List<StudioResponse> Studios { get; set; } = new List<StudioResponse>();
    }
}
