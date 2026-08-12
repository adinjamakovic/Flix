using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IMovieRecommendationService
    {
        Task GenerateRecommendationAsync();
        Task<List<MovieRecommendationResponse>> GetRecommendationsForMovieAsync(MovieRecommendationSearchObject search);
        Task DeleteOldRecommendations();
    }
}