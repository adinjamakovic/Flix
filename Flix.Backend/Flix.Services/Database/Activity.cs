using Flix.Model.Enums;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Flix.Services.Database
{
    public class Activity
    {
        [Key]
        public int Id { get; set; }
        public int UserId { get; set; }
        [ForeignKey(nameof(UserId))]
        public User User { get; set; } = null!;

        public ActivityType Type { get; set; }

        public int? MovieId { get; set; }
        [ForeignKey(nameof(MovieId))]
        public Movie? Movie { get; set; }

        public int? ReviewId { get; set; }
        [ForeignKey(nameof(ReviewId))]
        public Review? Review { get; set; }

        public int? ClashId { get; set; }
        [ForeignKey(nameof(ClashId))]
        public Clash? Clash { get; set; }

        public int? MovieListId { get; set; }
        [ForeignKey(nameof(MovieListId))]
        public MovieList? MovieList { get; set; }

        public int? TargetUserId { get; set; }
        [ForeignKey(nameof(TargetUserId))]
        public User? TargetUser { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
