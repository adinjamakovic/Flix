using Flix.Model.Enums;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Flix.Services.Database
{
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
        [MaxLength(150)]
        public string Header {get; set;} = string.Empty;
        [MaxLength(2000)]
        public string? Description { get; set; } = string.Empty;
        public ReportStatus Status { get; set; } = ReportStatus.Open;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public int? ReviewedByUserId { get; set; }
        [ForeignKey(nameof(ReviewedByUserId))]
        public User? ReviewedBy { get; set; }
        public DateTime? ResolvedAt { get; set; }
        [MaxLength(2000)]
        public string? AdminComment { get; set; }
    }
}
