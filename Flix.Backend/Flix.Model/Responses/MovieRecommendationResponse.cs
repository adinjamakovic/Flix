namespace Flix.Model.Responses
{
    public class MovieRecommendationResponse
    {
        public int Id {get; set;}
        public int MovieId {get; set;}
        public MovieResponse Movie { get; set; } = null!;
        public int RecommendedMovieId {get; set;}
        public MovieResponse RecommendedMovie {get; set;} = null!;
        public float Score { get; set; }
    }
}