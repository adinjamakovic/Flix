namespace Flix.Model.SearchObjects
{
    public class MovieRecommendationSearchObject
    {
        public int MovieId {get; set;}
        public int NumberOfRecommendations {get; set;} = 10;
    }
}