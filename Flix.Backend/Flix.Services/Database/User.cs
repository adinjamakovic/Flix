using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    public class User
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Username {  get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;

        public string PasswordSalt { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? LastLoginAt { get; set; }

        [Phone]
        [MaxLength(25)]
        public string? PhoneNumber { get; set; }

        public string? ProfileImageBase64 { get; set; }
        
        [MaxLength(500)]
        public string? Bio { get; set; }

        public int? CountryId { get; set; }
        [ForeignKey(nameof(CountryId))]
        public Country? Country { get; set; }

        // Authorization
        public ICollection<UserRole> Roles { get; set; } = new List<UserRole>();

        // Content authored by the user
        public ICollection<Review> Reviews { get; set; } = new List<Review>();
        public ICollection<MovieList> Lists { get; set; } = new List<MovieList>();
        // Social graph
        public ICollection<UserFollow> Following { get; set; } = new List<UserFollow>();
        public ICollection<UserFollow> Followers { get; set; } = new List<UserFollow>();

        // Competitions
        public ICollection<ClashEntry> ClashEntries { get; set; } = new List<ClashEntry>();
        // Refresh tokens for authentication
        public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    }
}
