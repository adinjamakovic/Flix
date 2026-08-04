using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Flix.Services.Database
{
    public class Genre
    {
        [Key]
        public int Id { get; set; }
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
    }
}
