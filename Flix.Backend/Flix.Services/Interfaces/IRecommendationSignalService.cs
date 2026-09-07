using Flix.Services.Recommendations;

namespace Flix.Services.Interfaces
{
    public interface IRecommendationSignalService
    {
        Task<IReadOnlyList<UserMovieSignal>> GetSignalsAsync(CancellationToken cancellationToken = default);

        Task<IReadOnlyList<MovieFeatures>> GetMovieFeaturesAsync(
            IReadOnlyCollection<int>? movieIds = null,
            CancellationToken cancellationToken = default);
    }
}
