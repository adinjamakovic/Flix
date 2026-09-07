using System.Net;
using DotNetEnv;
using EasyNetQ;
using Flix.Model.Messages;
using Flix.Model.Responses;
using Flix.Services.Database;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using MimeKit;
using MimeKit.Text;

var envFile = FindEnvFile(AppContext.BaseDirectory);

if (envFile is not null)
    Env.NoClobber().Load(envFile);

var rabbitMqHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
var rabbitMqUser = Environment.GetEnvironmentVariable("RABBITMQ_USER") ?? "guest";
var rabbitMqPass = Environment.GetEnvironmentVariable("RABBITMQ_PASS") ?? "guest";

var connectionString = $"host={rabbitMqHost};username={rabbitMqUser};password={rabbitMqPass}";

var smtpHost = Environment.GetEnvironmentVariable("SMTP_HOST") ?? "localhost";
var smtpPort = int.TryParse(Environment.GetEnvironmentVariable("SMTP_PORT"), out var parsedPort) ? parsedPort : 587;
var smtpFrom = Environment.GetEnvironmentVariable("SMTP_FROM") ?? "no-reply@flix.com"; // "ro-reply@flix.com" WILL NOT WORK as it is not a valid sender within my SMTP provider. Won't crash the app but emails will not be sent
var smtpFromName = Environment.GetEnvironmentVariable("SMTP_FROM_NAME") ?? "Flix";
var smtpUser = Environment.GetEnvironmentVariable("SMTP_USER") ?? smtpFrom;
var smtpPass = Environment.GetEnvironmentVariable("SMTP_PASS");

var databaseConnectionString = Environment.GetEnvironmentVariable("DATABASE_CONNECTION")
    ?? Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");

var fallbackAdminEmail = Environment.GetEnvironmentVariable("ADMIN_EMAIL");
var fallbackAdminName = Environment.GetEnvironmentVariable("ADMIN_NAME") ?? "Flix Admin";

var host = Host.CreateDefaultBuilder(args)
    .ConfigureAppConfiguration((context, config) =>
    {
        config.AddEnvironmentVariables();
    })
    .ConfigureServices(services =>
    {
        if (!string.IsNullOrWhiteSpace(databaseConnectionString))
            services.AddDbContext<FlixDbContext>(options => options.UseSqlServer(databaseConnectionString));
    })
    .Build();

var logger = host.Services.GetRequiredService<ILoggerFactory>().CreateLogger("Flix.Subscriber");

logger.LogInformation("Email RabbitMQ subscriber is starting");

if (envFile is null)
    logger.LogWarning("No .env found, reading configuration from environment variables only");
else
    logger.LogInformation("Loaded configuration from {EnvFile}", envFile);

logger.LogInformation("Connecting to RabbitMQ at {RabbitMqHost} as {RabbitMqUser}", rabbitMqHost, rabbitMqUser);

IBus bus;
try
{
    bus = RabbitHutch.CreateBus(connectionString);
}
catch (Exception e)
{
    logger.LogCritical(e, "Failed to create the RabbitMQ bus");
    return;
}

// 465 is implicit TLS, everything else negotiates over the plain port - a local dev
// relay (MailHog, Papercut) offers no TLS at all, hence WhenAvailable rather than StartTls.
var socketOptions = smtpPort == 465
    ? SecureSocketOptions.SslOnConnect
    : SecureSocketOptions.StartTlsWhenAvailable;

logger.LogInformation("Sending mail through {SmtpHost}:{SmtpPort} as {SmtpFrom}", smtpHost, smtpPort, smtpFrom);

if (string.IsNullOrWhiteSpace(databaseConnectionString))
    logger.LogWarning("No database connection configured, new movie requests will be announced to {AdminEmail}", fallbackAdminEmail ?? "nobody");
else
    logger.LogInformation("New movie requests will be announced to every active Admin in the database");

var subscriptions = new List<IDisposable>();

var subscribed = await TryAsync("Subscribing to messages", async () =>
{
    foreach (var subscription in subscriptions)
        subscription.Dispose();

    subscriptions.Clear();

    subscriptions.Add(await bus.PubSub.SubscribeAsync<MovieRequested>("movie_requested_email_sender", async message =>
    {
        logger.LogInformation("Received MovieRequested #{MessageId}: {Title}", message.Id, MovieTitle(message.Data));

        var admins = await GetAdminRecipientsAsync();

        if (admins.Count == 0)
        {
            logger.LogWarning("MovieRequested #{MessageId} has no admin recipient, skipping", message.Id);
            return;
        }

        await SendAsync(
            admins,
            $"New movie request: {MovieTitle(message.Data)}",
            BuildRequestedBody(message, await TryGetUserEmailAsync(message.Data?.RequestedByUser?.Id)));
    }));

    subscriptions.Add(await bus.PubSub.SubscribeAsync<MovieAccepted>("movie_accepted_email_sender", async message =>
    {
        logger.LogInformation("Received MovieAccepted #{MessageId}: {Title}", message.Id, MovieTitle(message.Data));

        var recipient = await GetRequesterRecipientAsync(message.Data?.RequestedByUser);

        if (recipient is null)
        {
            logger.LogWarning("MovieAccepted #{MessageId} has no requester email, skipping", message.Id);
            return;
        }

        await SendAsync(
            [recipient],
            $"Your movie request was accepted: {MovieTitle(message.Data)}",
            BuildAcceptedBody(message));
    }));

    subscriptions.Add(await bus.PubSub.SubscribeAsync<MovieRejected>("movie_rejected_email_sender", async message =>
    {
        logger.LogInformation("Received MovieRejected #{MessageId}: {Title}", message.Id, MovieTitle(message.Data));

        var recipient = await GetRequesterRecipientAsync(message.Data?.RequestedByUser);

        if (recipient is null)
        {
            logger.LogWarning("MovieRejected #{MessageId} has no requester email, skipping", message.Id);
            return;
        }

        await SendAsync(
            [recipient],
            $"Your movie request was rejected: {MovieTitle(message.Data)}",
            BuildRejectedBody(message));
    }));

    subscriptions.Add(await bus.PubSub.SubscribeAsync<PasswordResetRequested>("password_reset_email_sender", async message =>
    {
        logger.LogInformation("Received PasswordResetRequested #{MessageId} for user {UserId}", message.Id, message.Data?.UserId);

        var recipient = await GetUserRecipientAsync(message.Data?.UserId);

        if (recipient is null || string.IsNullOrWhiteSpace(message.Data?.Token))
        {
            logger.LogWarning("PasswordResetRequested #{MessageId} has no recipient or no code, skipping", message.Id);
            return;
        }

        await SendAsync(
            [recipient],
            "Your Flix password reset code",
            BuildPasswordResetBody(message, recipient.Name));
    }));
});

if (!subscribed)
{
    bus.Dispose();
    return;
}

logger.LogInformation("Listening for MovieRequested, MovieAccepted, MovieRejected and PasswordResetRequested messages");

// RunAsync rather than a Ctrl+C wait, so the container also stops on the SIGTERM docker sends.
await host.RunAsync();

logger.LogInformation("Subscriber is shutting down");

bus.Dispose();

async Task RetryAsync(string description, Func<Task> action, int maxAttempts = 5)
{
    for (var attempt = 1; ; attempt++)
    {
        try
        {
            await action();
            return;
        }
        catch (Exception e)
        {
            if (attempt == maxAttempts)
            {
                logger.LogError(e, "{Description} failed and gave up after {Attempts} attempts", description, attempt);
                throw;
            }

            var delay = TimeSpan.FromSeconds(Math.Pow(2, attempt - 1));

            logger.LogWarning(e, "{Description} failed, retrying in {DelaySeconds} seconds", description, (int)delay.TotalSeconds);
            await Task.Delay(delay);
        }
    }
}

async Task<bool> TryAsync(string description, Func<Task> action)
{
    try
    {
        await RetryAsync(description, action);
        return true;
    }
    catch
    {
        return false;
    }
}

async Task<string?> TryGetUserEmailAsync(int? userId)
{
    try
    {
        return await GetUserEmailAsync(userId);
    }
    catch
    {
        return null;
    }
}

async Task<List<MailboxAddress>> GetAdminRecipientsAsync()
{
    var recipients = new List<MailboxAddress>();

    if (!string.IsNullOrWhiteSpace(databaseConnectionString))
    {
        try
        {
            await RetryAsync("Reading admin emails from the database", async () =>
            {
                recipients.Clear();

                await using var scope = host.Services.CreateAsyncScope();

                var context = scope.ServiceProvider.GetRequiredService<FlixDbContext>();

                var admins = await context.Users
                    .AsNoTracking()
                    .Where(x => x.IsActive
                        && x.Email != string.Empty
                        && x.Roles.Any(role => role.Role.IsActive && role.Role.Name == "Admin"))
                    .OrderBy(x => x.Email)
                    .Select(x => new { x.Email, x.FirstName, x.LastName })
                    .ToListAsync();

                foreach (var admin in admins)
                {
                    var name = $"{admin.FirstName} {admin.LastName}".Trim();

                    recipients.Add(new MailboxAddress(
                        string.IsNullOrWhiteSpace(name) ? fallbackAdminName : name,
                        admin.Email));
                }
            });
        }
        catch (Exception e) when (!string.IsNullOrWhiteSpace(fallbackAdminEmail))
        {
            logger.LogWarning(e, "Falling back to {AdminEmail} after the database could not be read", fallbackAdminEmail);
            recipients.Clear();
        }
    }

    // The database is the source of truth; ADMIN_EMAIL only covers it being unreachable
    // or carrying no admin at all.
    if (recipients.Count == 0 && !string.IsNullOrWhiteSpace(fallbackAdminEmail))
        recipients.Add(new MailboxAddress(fallbackAdminName, fallbackAdminEmail));

    return recipients;
}

// MovieRequestResponse.RequestedByUser is the public profile DTO and carries no email, so the
// requester's address is read from the database per message the same way the admins' are.
async Task<MailboxAddress?> GetRequesterRecipientAsync(UserResponse? requester)
{
    if (requester is null)
        return null;

    var email = await GetUserEmailAsync(requester.Id);

    return string.IsNullOrWhiteSpace(email)
        ? null
        : new MailboxAddress(DisplayName(requester), email);
}


async Task<MailboxAddress?> GetUserRecipientAsync(int? userId)
{
    if (userId is not int id || string.IsNullOrWhiteSpace(databaseConnectionString))
        return null;

    MailboxAddress? recipient = null;

    await RetryAsync($"Reading the mailbox of user {id} from the database", async () =>
    {
        await using var scope = host.Services.CreateAsyncScope();

        var context = scope.ServiceProvider.GetRequiredService<FlixDbContext>();

        var user = await context.Users
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new { x.Email, x.FirstName, x.LastName, x.Username })
            .FirstOrDefaultAsync();

        if (user is null || string.IsNullOrWhiteSpace(user.Email))
            return;

        var name = $"{user.FirstName} {user.LastName}".Trim();

        recipient = new MailboxAddress(
            string.IsNullOrWhiteSpace(name) ? user.Username : name,
            user.Email);
    });

    return recipient;
}

async Task<string?> GetUserEmailAsync(int? userId)
{
    if (userId is not int id || string.IsNullOrWhiteSpace(databaseConnectionString))
        return null;

    string? email = null;

    await RetryAsync($"Reading the email of user {id} from the database", async () =>
    {
        await using var scope = host.Services.CreateAsyncScope();

        var context = scope.ServiceProvider.GetRequiredService<FlixDbContext>();

        email = await context.Users
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => x.Email)
            .FirstOrDefaultAsync();
    });

    return email;
}

async Task SendAsync(IReadOnlyCollection<MailboxAddress> recipients, string subject, string body)
{
    var addresses = string.Join(", ", recipients.Select(x => x.Address));

    var mail = new MimeMessage();
    mail.From.Add(new MailboxAddress(smtpFromName, smtpFrom));
    mail.To.AddRange(recipients);
    mail.Subject = subject;
    mail.Body = new TextPart(TextFormat.Html) { Text = body };

    await RetryAsync($"Sending \"{subject}\" to {addresses}", async () =>
    {
        using var client = new SmtpClient();

        await client.ConnectAsync(smtpHost, smtpPort, socketOptions);

        if (!string.IsNullOrWhiteSpace(smtpPass))
            await client.AuthenticateAsync(smtpUser, smtpPass);

        await client.SendAsync(mail);
        await client.DisconnectAsync(true);
    });

    logger.LogInformation("Sent \"{Subject}\" to {Recipients}", subject, addresses);
}

string BuildRequestedBody(MovieRequested message, string? requesterEmail)
{
    var data = message.Data;
    var requester = data?.RequestedByUser;

    return Wrap(
        "New movie request",
        $"""
        <p><strong>{Encode(DisplayName(requester))}</strong>{(string.IsNullOrWhiteSpace(requesterEmail) ? "" : $" ({Encode(requesterEmail)})")} requested a new movie.</p>
        {MovieBlock(data?.Movie)}
        <p>Request #{message.Id} was submitted on {Format(data?.CreatedAt)} and is waiting for review.</p>
        """);
}

string BuildAcceptedBody(MovieAccepted message)
{
    return Wrap(
        "Movie request accepted",
        $"""
        <p>Hi {Encode(DisplayName(message.Data?.RequestedByUser))},</p>
        <p>Your request for <strong>{Encode(MovieTitle(message.Data))}</strong> was accepted and the movie is now part of the Flix catalog.</p>
        {MovieBlock(message.Data?.Movie)}
        <p>Thanks for helping us grow the catalog.</p>
        """);
}

string BuildRejectedBody(MovieRejected message)
{
    var reason = message.Data?.AdminComment;

    var reasonBlock = string.IsNullOrWhiteSpace(reason)
        ? string.Empty
        : $"""
            <table cellpadding="4" cellspacing="0" style="border-collapse:collapse">
                <tr><td><strong>Reason</strong></td><td>{Encode(reason)}</td></tr>
            </table>
            """;

    return Wrap(
        "Movie request rejected",
        $"""
        <p>Hi {Encode(DisplayName(message.Data?.RequestedByUser))},</p>
        <p>Your request for <strong>{Encode(MovieTitle(message.Data))}</strong> was reviewed and will not be added to the catalog.</p>
        {reasonBlock}
        <p>You are welcome to submit another request at any time.</p>
        """);
}

string BuildPasswordResetBody(PasswordResetRequested message, string recipientName)
{
    var data = message.Data!;
    var minutes = Math.Max(1, (int)Math.Round((data.ExpiresAt - DateTime.UtcNow).TotalMinutes));

    return Wrap(
        "Password reset",
        $"""
        <p>Hi {Encode(recipientName)},</p>
        <p>Use this code in the Flix app to set a new password:</p>
        <p style="font-size:28px;font-weight:bold;letter-spacing:6px">{Encode(data.Token)}</p>
        <p>It stops working in {minutes} minutes, at {Format(data.ExpiresAt)}, and can only be used once.</p>
        <p>If you did not ask for this, ignore this email - your password stays as it is.</p>
        """);
}

static string MovieBlock(MovieResponse? movie)
{
    if (movie is null)
        return string.Empty;

    var year = movie.ReleaseDate?.Year.ToString() ?? "unknown year";
    var directors = movie.Directors.Count > 0
        ? string.Join(", ", movie.Directors.Select(x => $"{x.FirstName} {x.LastName}".Trim()))
        : "not provided";
    var genres = movie.Genres.Count > 0
        ? string.Join(", ", movie.Genres.Select(x => x.Name))
        : "not provided";

    return $"""
        <table cellpadding="4" cellspacing="0" style="border-collapse:collapse">
            <tr><td><strong>Title</strong></td><td>{Encode(movie.Title)}</td></tr>
            <tr><td><strong>Year</strong></td><td>{Encode(year)}</td></tr>
            <tr><td><strong>Director</strong></td><td>{Encode(directors)}</td></tr>
            <tr><td><strong>Genre</strong></td><td>{Encode(genres)}</td></tr>
            <tr><td><strong>Description</strong></td><td>{Encode(string.IsNullOrWhiteSpace(movie.Description) ? "not provided" : movie.Description)}</td></tr>
        </table>
        """;
}

static string Wrap(string heading, string body)
    => $"""
        <html>
            <body style="font-family:Segoe UI,Arial,sans-serif;font-size:14px;color:#111">
                <h2>{Encode(heading)}</h2>
                {body}
                <p style="color:#777;font-size:12px">Flix</p>
            </body>
        </html>
        """;

static string MovieTitle(MovieRequestResponse? data)
    => string.IsNullOrWhiteSpace(data?.Movie?.Title) ? "Untitled" : data!.Movie!.Title;

static string DisplayName(UserResponse? user)
{
    if (user is null)
        return "there";

    var fullName = $"{user.FirstName} {user.LastName}".Trim();

    return string.IsNullOrWhiteSpace(fullName)
        ? (string.IsNullOrWhiteSpace(user.Username) ? "there" : user.Username)
        : fullName;
}

static string Format(DateTime? value)
    => value is null ? "an unknown date" : value.Value.ToLocalTime().ToString("dd/MM/yyyy HH:mm");

static string Encode(string? value) => WebUtility.HtmlEncode(value ?? string.Empty);

static string? FindEnvFile(string startDirectory)
{
    var directory = new DirectoryInfo(startDirectory);

    while (directory is not null)
    {
        var candidate = Path.Combine(directory.FullName, ".env");

        if (File.Exists(candidate))
            return candidate;

        directory = directory.Parent;
    }

    return null;
}
