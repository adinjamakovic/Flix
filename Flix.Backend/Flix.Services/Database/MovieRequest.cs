using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    /// <summary>
    /// A request submitted by a user to add a movie that is not yet in the system.
    /// The administrator reviews it, completes the cast, and approves or rejects it.
    /// </summary>
    public class MovieRequest
    {
        [Key]
        public int Id { get; set; }
        public int RequestedByUserId { get; set; }
        [ForeignKey(nameof(RequestedByUserId))]
        public User RequestedBy { get; set; } = null!;
        public int? CreatedMovieId { get; set; }
        [ForeignKey(nameof(CreatedMovieId))]
        public Movie? CreatedMovie { get; set; }
        public MovieRequestStatus Status { get; set; } = MovieRequestStatus.Pending;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public int? ReviewedByUserId { get; set; }
        [ForeignKey(nameof(ReviewedByUserId))]
        public User? ReviewedBy { get; set; }

        public DateTime? ReviewedAt { get; set; }

    }
}
