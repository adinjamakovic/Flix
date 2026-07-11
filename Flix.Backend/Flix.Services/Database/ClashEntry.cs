using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    /// <summary>
    /// A user's participation in a <see cref="Clash"/>: the themed movie list they
    /// submitted. Other users cast votes on entries; the entry with the most votes
    /// wins the competition.
    /// </summary>
    public class ClashEntry
    {
        [Key]
        public int Id { get; set; }

        public int ClashId { get; set; }
        [Required]
        [ForeignKey(nameof(ClashId))]
        public Clash Clash { get; set; } = null!;

        /// <summary>The participating user.</summary>
        public int UserId { get; set; }
        [Required]
        [ForeignKey(nameof(UserId))]
        public User User { get; set; } = null!;

        /// <summary>The list submitted to the competition.</summary>
        public int MovieListId { get; set; }
        [Required]
        [ForeignKey(nameof(MovieListId))]
        public MovieList MovieList { get; set; } = null!;

        /// <summary>True for the winning entry once the clash is completed.</summary>
        public bool IsWinner { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<ClashVote> Votes { get; set; } = new List<ClashVote>();
    }
}
