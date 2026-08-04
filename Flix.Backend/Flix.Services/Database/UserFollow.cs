using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Flix.Services.Database
{
    public class UserFollow
    {
        [Key]
        public int Id { get; set; }

        /// <summary>The user who initiated the follow.</summary>
        public int FollowerId { get; set; }
        [Required]
        [ForeignKey(nameof(FollowerId))]
        public User Follower { get; set; } = null!;

        /// <summary>The user being followed.</summary>
        public int FollowingId { get; set; }
        [Required]
        [ForeignKey(nameof(FollowingId))]
        public User Followee { get; set; } = null!;
        public bool IsFriend {  get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
