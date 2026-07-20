using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    public class ClashEntry
    {
        [Key]
        public int Id { get; set; }

        public int ClashId { get; set; }
        [Required]
        [ForeignKey(nameof(ClashId))]
        public Clash Clash { get; set; } = null!;

        public int UserId { get; set; }
        [Required]
        [ForeignKey(nameof(UserId))]
        public User User { get; set; } = null!;

        public int MovieListId { get; set; }
        [Required]
        [ForeignKey(nameof(MovieListId))]
        public MovieList MovieList { get; set; } = null!;

        public bool IsWinner { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<ClashVote> Votes { get; set; } = new List<ClashVote>();
    }
}
