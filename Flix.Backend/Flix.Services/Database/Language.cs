using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Flix.Services.Database
{
    public class Language
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(60)]
        public string Name { get; set; } = string.Empty;

        /// <summary>ISO 639-1 code (e.g. en, ja, hr).</summary>
        [MaxLength(5)]
        public string? Code { get; set; }

        public ICollection<Movie> Movies { get; set; } = new List<Movie>();
    }
}
