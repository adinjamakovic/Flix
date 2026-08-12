using System.ComponentModel.DataAnnotations;

namespace Flix.Services.Database
{
    public class MovieRecommendation
    {
        [Key]
        public int Id {get; set;}
        public int MovieId {get; set;}
        public Movie Movie { get; set; } = null!;
        public int RecommendedMovieId {get; set;}
        public Movie RecommendedMovie {get; set;} = null!;
        [Required]
        public float Score { get; set; }
    }
}