using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    public class ClashVote
    {
        [Key]
        public int Id { get; set; }

        public int ClashEntryId { get; set; }
        [Required]
        [ForeignKey(nameof(ClashEntryId))]
        public ClashEntry ClashEntry { get; set; } = null!;

        public int VoterId { get; set; }
        [Required]
        [ForeignKey(nameof(VoterId))]
        public User Voter { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
