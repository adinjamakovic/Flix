namespace Flix.Model.Responses
{
    public class AdminStatisticsResponse
    {
        public int ActiveUsers {get; set;}
        public decimal UserPercentage {get; set;}
        public int TotalMovies {get; set;}
        public decimal MoviePercentage {get; set;}
        public int TotalReviews {get; set;}
        public decimal ReviewPercentage {get; set;}
        public int TotalClashes {get; set;}
        public decimal ClashPercentage {get; set;}
        public List<UserResponse> MostActiveUsers {get; set;} = new();
        public List<MovieResponse> MostPopularMovies {get; set;} = new();
        public List<ActivityResponse> RecentActivity {get; set;} = new();
        public List<GenrePercentageResponse> GenrePercentages {get; set;} = new();
    }
}