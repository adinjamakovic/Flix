using Flix.Services.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    public class UserReport
    {
        [Key]
        public int Id { get; set; }
       
        public int ReporterId { get; set; }
        [ForeignKey(nameof(ReporterId))]
        public User Reporter { get; set; } = null!;

        public int ReportedUserId { get; set; }
        [ForeignKey(nameof(ReportedUserId))]
        public User ReportedUser { get; set; } = null!;

        [Required]
        [MaxLength(1000)]
        public string Reason { get; set; } = string.Empty;

        public ReportStatus Status { get; set; } = ReportStatus.Open;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public int? ReviewedByUserId { get; set; }
        [ForeignKey(nameof(ReviewedByUserId))]
        public User? ReviewedBy { get; set; }
        public DateTime? ResolvedAt { get; set; }
        public string? AdminComment { get; set; }
    }
}
