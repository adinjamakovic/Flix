using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Flix.Services.Database
{
    public class Movie
    {
        [Key]
        public int Id { get; set; }
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; } = string.Empty;
        public string? Poster { get; set; }
        public string? HeaderImage { get; set; }
        public string? TrailerUrl { get; set; }

        public DateTime? ReleaseDate { get; set; }

        public int? DurationMinutes { get; set; }

        public int Views { get; set; }
        public bool IsEnabled { get; set; }

        public int? CountryId { get; set; }
        [ForeignKey(nameof(CountryId))]
        public Country? Country { get; set; }

        public int? LanguageId { get; set; }
        [ForeignKey(nameof(LanguageId))]
        public Language? Language { get; set; }

        public ICollection<Genre> Genres { get; set; } = new List<Genre>();

        public ICollection<MovieCast> Credits { get; set; } = new List<MovieCast>();

        public ICollection<Review> Reviews { get; set; } = new List<Review>();
        public ICollection<MovieStudio> Studios { get; set; } = new List<MovieStudio>();
    }
}
