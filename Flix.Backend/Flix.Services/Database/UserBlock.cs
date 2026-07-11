using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    /// <summary>
    /// A user blocking another user (the "Blocked" tab on the network screen).
    /// </summary>
    public class UserBlock
    {
        [Key]
        public int Id { get; set; }

        public int BlockerId { get; set; }
        [Required]
        [ForeignKey(nameof(BlockerId))]
        public User Blocker { get; set; } = null!;

        public int BlockedId { get; set; }
        [Required]
        [ForeignKey(nameof(BlockedId))]
        public User Blocked { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
