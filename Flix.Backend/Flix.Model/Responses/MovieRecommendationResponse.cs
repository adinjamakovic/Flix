using Flix.Model.Enums;

namespace Flix.Model.Responses
{
    public class MovieRecommendationResponse
    {
        public int? Id {get; set;}
        public int? MovieId {get; set;}
        public MovieResponse? Movie { get; set; }
        public int RecommendedMovieId {get; set;}
        public MovieResponse RecommendedMovie {get; set;} = null!;
        public float Score { get; set; }
        public RecommendationSource Source { get; set; }
    }
}