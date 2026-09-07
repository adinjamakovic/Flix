using EasyNetQ;
using Flix.Services.Database;
using Flix.Services.Implementations;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Flix.Services.BackgroundServices
{
    public class OutboxDispatcherService(IServiceProvider services, ILogger<OutboxDispatcherService> logger)
        : BackgroundService
    {
        private static readonly TimeSpan Interval = TimeSpan.FromSeconds(5);
        private static readonly TimeSpan MaxBackoff = TimeSpan.FromMinutes(5);
        private const int BatchSize = 20;
        private const int MaxAttempts = 10;

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            using var timer = new PeriodicTimer(Interval);

            try
            {
                do
                {
                    try
                    {
                        await DispatchAsync(stoppingToken);
                    }
                    catch (Exception ex) when (ex is not OperationCanceledException)
                    {
                        logger.LogError(ex, "Outbox dispatch failed.");
                    }
                }
                while (await timer.WaitForNextTickAsync(stoppingToken));
            }
            catch (OperationCanceledException)
            {
            }
        }

        private async Task DispatchAsync(CancellationToken ct)
        {
            using var scope = services.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<FlixDbContext>();

            var now = DateTime.UtcNow;

            var pending = await context.OutboxMessages
                .Where(x => x.ProcessedAt == null && x.Attempts < MaxAttempts && x.NextAttemptAt <= now)
                .OrderBy(x => x.Id)
                .Take(BatchSize)
                .ToListAsync(ct);

            if (pending.Count == 0)
                return;

            var bus = scope.ServiceProvider.GetRequiredService<IBus>();

            foreach (var message in pending)
            {
                try
                {
                    await OutboxMessageRegistry.PublishAsync(message.Type, message.Payload, bus, ct);

                    message.ProcessedAt = DateTime.UtcNow;
                    message.LastError = null;

                    message.Payload = string.Empty;
                }
                catch (Exception ex) when (ex is not OperationCanceledException)
                {
                    message.Attempts++;
                    message.LastError = ex.Message.Length > 1000 ? ex.Message[..1000] : ex.Message;
                    message.NextAttemptAt = DateTime.UtcNow.Add(Backoff(message.Attempts));

                    if (message.Attempts >= MaxAttempts)
                        logger.LogError(
                            ex,
                            "Outbox message {MessageId} ({MessageType}) was given up on after {Attempts} attempts and stays unpublished.",
                            message.Id,
                            message.Type,
                            message.Attempts);
                    else
                        logger.LogWarning(
                            ex,
                            "Outbox message {MessageId} ({MessageType}) failed on attempt {Attempts}, retrying at {NextAttemptAt}.",
                            message.Id,
                            message.Type,
                            message.Attempts,
                            message.NextAttemptAt);
                }
            }

            // Not the stopping token: a shutdown landing between the publish and this save
            // would republish the whole batch on the next start.
            await context.SaveChangesAsync(CancellationToken.None);
        }

        private static TimeSpan Backoff(int attempts)
        {
            var delay = TimeSpan.FromSeconds(Math.Pow(2, attempts));

            return delay < MaxBackoff ? delay : MaxBackoff;
        }
    }
}
