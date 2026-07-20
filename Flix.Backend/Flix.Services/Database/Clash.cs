using Flix.Services.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

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

        public string? BannerImageBase64 { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<ClashEntry> Entries { get; set; } = new List<ClashEntry>();
    }
}
