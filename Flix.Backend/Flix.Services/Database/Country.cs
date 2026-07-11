using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Flix.Services.Database
{
    /// <summary>
    /// Country of origin for movies and the home country of users.
    /// Used by the search/filter drop-downs on both modules.
    /// </summary>
    public class Country
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        /// <summary>ISO-style short code shown in the admin tables (e.g. USA, JP, HR).</summary>
        [MaxLength(5)]
        public string? Code { get; set; }
        public string? FlagImageBase64 { get; set; }
        public ICollection<Movie> Movies { get; set; } = new List<Movie>();
        public ICollection<User> Users { get; set; } = new List<User>();
    }
}
