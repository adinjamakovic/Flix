using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    public class MovieStudio
    {
        [Key]
        public int Id { get; set; }
        public int MovieId { get; set; }
        [Required]
        [ForeignKey(nameof(MovieId))]
        public Movie Movie { get; set; } = null!;
        public int StudioId { get; set; }
        [Required]
        [ForeignKey(nameof(StudioId))]
        public Studio Studio { get; set; } = null!;
    }
}
