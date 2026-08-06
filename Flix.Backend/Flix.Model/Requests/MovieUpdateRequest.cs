using Microsoft.AspNetCore.Http;

namespace Flix.Model.Requests
{
    public class MovieUpdateRequest
    {
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? TrailerUrl { get; set; }
        public DateTime? ReleaseDate { get; set; }
        public int? DurationMinutes { get; set; }
        public bool IsEnabled { get; set; } = true;
        public IFormFile? MoviePoster { get; set; }
        public IFormFile? HeaderImage { get; set; }
        public int? CountryId { get; set; }
        public int? LanguageId { get; set; }
        public List<int>? GenreIds { get; set; }
        public List<MovieCreditRequest>? Credits { get; set; }
    }
}
