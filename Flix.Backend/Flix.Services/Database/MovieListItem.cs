using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    public class MovieListItem
    {
        [Key]
        public int Id { get; set; }

        public int MovieListId { get; set; }
        [Required]
        [ForeignKey(nameof(MovieListId))]
        public MovieList MovieList { get; set; } = null!;

        public int MovieId { get; set; }
        [Required]
        [ForeignKey(nameof(MovieId))]
        public Movie Movie { get; set; } = null!;

        /// <summary>Position of the movie within the list.</summary>
        public int Position { get; set; }

        public DateTime AddedAt { get; set; } = DateTime.UtcNow;
    }
}
