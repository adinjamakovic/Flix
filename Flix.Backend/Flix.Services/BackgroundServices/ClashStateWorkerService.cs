using Flix.Model.Enums;
using Flix.Services.Database;
using Flix.Services.StateMachines;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Flix.Services.BackgroundServices
{
    public class ClashStateWorkerService(IServiceProvider services, ILogger<ClashStateWorkerService> logger)
        : BackgroundService
    {
        private static readonly TimeSpan Interval = TimeSpan.FromMinutes(1);

        private static readonly ClashStatus[] CanComplete =
            [.. Transitions.Clash.SourcesOf(ClashStatus.Completed)];

        private static readonly ClashStatus[] CanActivate =
            [.. Transitions.Clash.SourcesOf(ClashStatus.Active)];

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            using var timer = new PeriodicTimer(Interval);

            try
            {
                do
                {
                    try
                    {
                        await SweepAsync(stoppingToken);
                    }
                    catch (Exception ex) when (ex is not OperationCanceledException)
                    {
                        logger.LogError(ex, "Clash state sweep failed.");
                    }
                }
                while (await timer.WaitForNextTickAsync(stoppingToken));
            }
            catch (OperationCanceledException)
            {
            }
        }

        private async Task SweepAsync(CancellationToken ct)
        {
            using var scope = services.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<FlixDbContext>();

            var now = DateTime.UtcNow;

            var completed = await context.Clashes
                .Include(c => c.Entries)
                    .ThenInclude(e => e.Votes)
                .Where(c => CanComplete.Contains(c.Status) && c.EndDate < now)
                .AsSplitQuery()
                .ToListAsync(ct);

            foreach (var clash in completed)
            {
                clash.Status = ClashStatus.Completed;
                AssignWinner(clash);
            }

            var started = await context.Clashes
                .Where(c => CanActivate.Contains(c.Status) && c.StartDate <= now && c.EndDate >= now)
                .ToListAsync(ct);

            foreach (var clash in started)
                clash.Status = ClashStatus.Active;

            if (completed.Count == 0 && started.Count == 0)
                return;

            await context.SaveChangesAsync(ct);

            logger.LogInformation(
                "Clash state sweep: {Started} started, {Completed} completed.",
                started.Count,
                completed.Count);
        }

        private static void AssignWinner(Clash clash)
        {
            var winner = clash.Entries
                .Where(e => e.Votes.Count > 0)
                .OrderByDescending(e => e.Votes.Count)
                .ThenBy(e => e.CreatedAt)
                .ThenBy(e => e.Id)
                .FirstOrDefault();

            foreach (var entry in clash.Entries)
                entry.IsWinner = entry == winner;
        }
    }
}
