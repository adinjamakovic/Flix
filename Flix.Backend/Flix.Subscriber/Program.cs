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
using MimeKit;
using MimeKit.Text;

Console.WriteLine("Email RabbitMQ subscriber is starting");

var envFile = FindEnvFile(AppContext.BaseDirectory);

if (envFile is null)
    Console.WriteLine("No .env found, reading configuration from environment variables only");
else
{
    Env.NoClobber().Load(envFile);
    Console.WriteLine($"Loaded configuration from {envFile}");
}

var rabbitMqHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
var rabbitMqUser = Environment.GetEnvironmentVariable("RABBITMQ_USER") ?? "guest";
var rabbitMqPass = Environment.GetEnvironmentVariable("RABBITMQ_PASS") ?? "guest";

var connectionString = $"host={rabbitMqHost};username={rabbitMqUser};password={rabbitMqPass}";

Console.WriteLine($"Connecting to RabbitMQ at {rabbitMqHost} as {rabbitMqUser}");

IBus bus;
try
{
    bus = RabbitHutch.CreateBus(connectionString);
}
catch (Exception e)
{
    Console.WriteLine($"Failed to create the RabbitMQ bus: {e.GetBaseException().Message}");
    return;
}

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

// 465 is implicit TLS, everything else negotiates over the plain port - a local dev
// relay (MailHog, Papercut) offers no TLS at all, hence WhenAvailable rather than StartTls.
var socketOptions = smtpPort == 465
    ? SecureSocketOptions.SslOnConnect
    : SecureSocketOptions.StartTlsWhenAvailable;

Console.WriteLine($"Sending mail through {smtpHost}:{smtpPort} as {smtpFrom}");
Console.WriteLine(string.IsNullOrWhiteSpace(databaseConnectionString)
    ? $"No database connection configured, new movie requests will be announced to {fallbackAdminEmail ?? "nobody"}"
    : "New movie requests will be announced to every active Admin in the database");

var subscriptions = new List<IDisposable>();

var subscribed = await RetryAsync("Subscribing to messages", async () =>
{
    foreach (var subscription in subscriptions)
        subscription.Dispose();

    subscriptions.Clear();

    subscriptions.Add(await bus.PubSub.SubscribeAsync<MovieRequested>("movie_requested_email_sender", async message =>
    {
        Console.WriteLine($"Received MovieRequested #{message.Id}: {MovieTitle(message.Data)}");

        var admins = await GetAdminRecipientsAsync();

        if (admins.Count == 0)
        {
            Console.WriteLine($"MovieRequested #{message.Id} has no admin recipient, skipping");
            return;
        }

        await SendAsync(
            admins,
            $"New movie request: {MovieTitle(message.Data)}",
            BuildRequestedBody(message));
    }));

    subscriptions.Add(await bus.PubSub.SubscribeAsync<MovieAccepted>("movie_accepted_email_sender", async message =>
    {
        Console.WriteLine($"Received MovieAccepted #{message.Id}: {MovieTitle(message.Data)}");

        var recipient = message.Data?.RequestedByUser;

        if (recipient is null || string.IsNullOrWhiteSpace(recipient.Email))
        {
            Console.WriteLine($"MovieAccepted #{message.Id} has no requester email, skipping");
            return;
        }

        await SendAsync(
            [new MailboxAddress(DisplayName(recipient), recipient.Email)],
            $"Your movie request was accepted: {MovieTitle(message.Data)}",
            BuildAcceptedBody(message));
    }));

    subscriptions.Add(await bus.PubSub.SubscribeAsync<MovieRejected>("movie_rejected_email_sender", async message =>
    {
        Console.WriteLine($"Received MovieRejected #{message.Id}: {MovieTitle(message.Data)}");

        var recipient = message.Data?.RequestedByUser;

        if (recipient is null || string.IsNullOrWhiteSpace(recipient.Email))
        {
            Console.WriteLine($"MovieRejected #{message.Id} has no requester email, skipping");
            return;
        }

        await SendAsync(
            [new MailboxAddress(DisplayName(recipient), recipient.Email)],
            $"Your movie request was rejected: {MovieTitle(message.Data)}",
            BuildRejectedBody(message));
    }));
});

if (!subscribed)
{
    bus.Dispose();
    return;
}

Console.WriteLine("Listening for MovieRequested, MovieAccepted and MovieRejected messages");

// RunAsync rather than a Ctrl+C wait, so the container also stops on the SIGTERM docker sends.
await host.RunAsync();

Console.WriteLine("Subscriber is shutting down");

bus.Dispose();

static async Task<bool> RetryAsync(string description, Func<Task> action, int maxAttempts = 5)
{
    for (var attempt = 1; ; attempt++)
    {
        try
        {
            await action();
            return true;
        }
        catch (Exception e)
        {
            Console.WriteLine($"{description} failed: {e.GetBaseException().Message}");

            if (attempt == maxAttempts)
            {
                Console.WriteLine($"{description} gave up after {attempt} attempts");
                return false;
            }

            var delay = TimeSpan.FromSeconds(Math.Pow(2, attempt - 1));

            Console.WriteLine($"Retrying in {delay.TotalSeconds:0} seconds");
            await Task.Delay(delay);
        }
    }
}

async Task<List<MailboxAddress>> GetAdminRecipientsAsync()
{
    var recipients = new List<MailboxAddress>();

    if (!string.IsNullOrWhiteSpace(databaseConnectionString))
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

    // The database is the source of truth; ADMIN_EMAIL only covers it being unreachable
    // or carrying no admin at all.
    if (recipients.Count == 0 && !string.IsNullOrWhiteSpace(fallbackAdminEmail))
        recipients.Add(new MailboxAddress(fallbackAdminName, fallbackAdminEmail));

    return recipients;
}

async Task SendAsync(IReadOnlyCollection<MailboxAddress> recipients, string subject, string body)
{
    var addresses = string.Join(", ", recipients.Select(x => x.Address));

    var mail = new MimeMessage();
    mail.From.Add(new MailboxAddress(smtpFromName, smtpFrom));
    mail.To.AddRange(recipients);
    mail.Subject = subject;
    mail.Body = new TextPart(TextFormat.Html) { Text = body };

    var sent = await RetryAsync($"Sending \"{subject}\" to {addresses}", async () =>
    {
        using var client = new SmtpClient();

        await client.ConnectAsync(smtpHost, smtpPort, socketOptions);

        if (!string.IsNullOrWhiteSpace(smtpPass))
            await client.AuthenticateAsync(smtpUser, smtpPass);

        await client.SendAsync(mail);
        await client.DisconnectAsync(true);
    });

    if (sent)
        Console.WriteLine($"Sent \"{subject}\" to {addresses}");
}

string BuildRequestedBody(MovieRequested message)
{
    var data = message.Data;
    var requester = data?.RequestedByUser;

    return Wrap(
        "New movie request",
        $"""
        <p><strong>{Encode(DisplayName(requester))}</strong>{(string.IsNullOrWhiteSpace(requester?.Email) ? "" : $" ({Encode(requester!.Email)})")} requested a new movie.</p>
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
    return Wrap(
        "Movie request rejected",
        $"""
        <p>Hi {Encode(DisplayName(message.Data?.RequestedByUser))},</p>
        <p>Your request for <strong>{Encode(MovieTitle(message.Data))}</strong> was reviewed and will not be added to the catalog.</p>
        <p>You are welcome to submit another request at any time.</p>
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
