using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Flix.Services.Database
{
    public class Country
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(5)]
        public string? Code { get; set; }
        public string? FlagImage { get; set; }
        public ICollection<Movie> Movies { get; set; } = new List<Movie>();
        public ICollection<User> Users { get; set; } = new List<User>();
    }
}
