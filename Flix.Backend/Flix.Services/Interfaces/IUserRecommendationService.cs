using Flix.Model.Responses;

namespace Flix.Services.Interfaces
{
    public interface IUserRecommendationService
    {
        Task<PageResult<MovieRecommendationResponse>> GetRecommendationsForUserAsync(int userId);
    }
}
