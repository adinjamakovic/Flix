using Flix.Services.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Flix.Services.BackgroundServices
{
    public class MovieRecommendationWorkerService(
        IServiceProvider services,
        ILogger<MovieRecommendationWorkerService> logger) : BackgroundService
    {
        private static readonly TimeSpan Interval = TimeSpan.FromMinutes(30);

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            using var timer = new PeriodicTimer(Interval);

            try
            {
                do
                {
                    try
                    {
                        await GenerateAsync();
                    }
                    catch (Exception ex) when (ex is not OperationCanceledException)
                    {
                        logger.LogError(ex, "Movie recommendation generation failed.");
                    }
                }
                while (await timer.WaitForNextTickAsync(stoppingToken));
            }
            catch (OperationCanceledException)
            {
            }
        }

        private async Task GenerateAsync()
        {
            using var scope = services.CreateScope();
            var recommendationService = scope.ServiceProvider.GetRequiredService<IMovieRecommendationService>();

            logger.LogInformation("Generating movie recommendations.");

            await recommendationService.GenerateRecommendationAsync();

            logger.LogInformation("Movie recommendation generation finished.");
        }
    }
}
