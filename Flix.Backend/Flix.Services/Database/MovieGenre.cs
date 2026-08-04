using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Flix.Services.Database
{
    public class MovieGenre
    {
        [Key]
        public int Id { get; set; }
        // Movie
        public int MovieId { get; set; }
        [Required]
        [ForeignKey("MovieId")]
        public Movie Movie { get; set; } = null!;
        // Genre
        public int GenreId { get; set; }
        [Required]
        [ForeignKey("GenreId")]
        public Genre Genre { get; set; } = null!;
    }
}
