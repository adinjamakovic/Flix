using Flix.Model.Enums;
using System.ComponentModel.DataAnnotations;

namespace Flix.Services.Database
{
    public class Clash
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        [Required]
        public string Description { get; set; } = string.Empty;

        public ClashStatus Status { get; set; } = ClashStatus.Upcoming;

        public DateTime StartDate { get; set; }

        public DateTime EndDate { get; set; }

        public string? BannerImage { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<ClashEntry> Entries { get; set; } = new List<ClashEntry>();
    }
}
