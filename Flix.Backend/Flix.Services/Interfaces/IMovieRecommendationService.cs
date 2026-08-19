using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IMovieRecommendationService
    {
        Task GenerateRecommendationAsync();
        Task<PageResult<MovieRecommendationResponse>> GetRecommendationsForMovieAsync(MovieRecommendationSearchObject search);
        Task DeleteOldRecommendations();
        Task<PageResult<MovieRecommendationResponse>> GetRecommendationsForUserAsync(int userId);
    }
}