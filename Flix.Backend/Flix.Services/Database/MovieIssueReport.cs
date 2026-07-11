using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    /// <summary>
    /// A user-submitted "Report an issue" about a movie's details (wrong metadata,
    /// missing cast, etc.) raised from the movie detail screen.
    /// </summary>
    public class MovieIssueReport
    {
        [Key]
        public int Id { get; set; }

        public int MovieId { get; set; }
        [ForeignKey(nameof(MovieId))]
        public Movie Movie { get; set; } = null!;

        public int ReportedByUserId { get; set; }
        [ForeignKey(nameof(ReportedByUserId))]
        public User ReportedBy { get; set; } = null!;

        [Required]
        [MaxLength(2000)]
        public string Description { get; set; } = string.Empty;

        public ReportStatus Status { get; set; } = ReportStatus.Open;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public int? ReviewedByUserId { get; set; }
        [ForeignKey(nameof(ReviewedByUserId))]
        public User? ReviewedBy { get; set; }
        public DateTime? ResolvedAt { get; set; }
        public string? AdminComment { get; set; }
    }
}
