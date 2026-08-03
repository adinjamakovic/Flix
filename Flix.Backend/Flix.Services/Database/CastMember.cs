using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    public class CastMember
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
        public int CountryId { get; set; }
        [Required]
        [ForeignKey(nameof(CountryId))]
        public Country Country { get; set; } = null!;
        public DateTime? BirthDate { get; set; }

        public string? Biography { get; set; }

        public string? PhotoBase64 { get; set; }

        public ICollection<MovieCast> Credits { get; set; } = new List<MovieCast>();
    }
}
