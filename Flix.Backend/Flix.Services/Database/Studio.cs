using System.ComponentModel.DataAnnotations;

namespace Flix.Services.Database
{
    public class Studio
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public string? Description { get; set; }
        public string? Logo { get; set; }

        public ICollection<MovieStudio> Movies { get; set; } = new List<MovieStudio>();
    }
}
