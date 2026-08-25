using Flix.Model.Responses;

namespace Flix.Services.Interfaces
{
    public interface IStatisticsService
    {
        public Task<AdminStatisticsResponse> GetStatistics();
    }
}