using Flix.Model.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Flix.Services.Database
{
    public class MovieCast
    {
        [Key]
        public int Id { get; set; }

        public int MovieId { get; set; }
        [Required]
        [ForeignKey(nameof(MovieId))]
        public Movie Movie { get; set; } = null!;

        public int CastMemberId { get; set; }
        [Required]
        [ForeignKey(nameof(CastMemberId))]
        public CastMember CastMember { get; set; } = null!;

        public CastRole Role { get; set; }

        [MaxLength(100)]
        public string? CharacterName { get; set; }

        public int OrderOfAppearence { get; set; }
    }
}
