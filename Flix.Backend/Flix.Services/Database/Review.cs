using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Flix.Services.Database
{
    public class Review
    {
        [Key]
        public int Id { get; set; }

        public int UserId { get; set; }
        [ForeignKey(nameof(UserId))]
        public User User { get; set; } = null!;

        public int MovieId { get; set; }
        [ForeignKey(nameof(MovieId))]
        public Movie Movie { get; set; } = null!;
        
        [Column(TypeName = "decimal(2,1)")]
        [Range(0.5, 5.0)]
        public decimal? Rating { get; set; }
        public bool IsLiked { get; set; }
        [Required]
        public string Content { get; set; } = string.Empty;

        public bool ContainsSpoilers { get; set; }
        public bool IsDiaryEntry { get; set; }
        public bool IsRewatch { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }
    }
}
