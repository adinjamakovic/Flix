using EasyNetQ;
using Flix.Model.Messages;
using JsonSerializer = System.Text.Json.JsonSerializer;
using JsonSerializerDefaults = System.Text.Json.JsonSerializerDefaults;
using JsonSerializerOptions = System.Text.Json.JsonSerializerOptions;

namespace Flix.Services.Implementations
{
    public static class OutboxMessageRegistry
    {
        public static readonly JsonSerializerOptions SerializerOptions = new(JsonSerializerDefaults.Web);

        private static readonly Dictionary<string, Func<string, IBus, CancellationToken, Task>> Publishers = new()
        {
            [nameof(MovieRequested)] = PublisherFor<MovieRequested>(),
            [nameof(MovieAccepted)] = PublisherFor<MovieAccepted>(),
            [nameof(MovieRejected)] = PublisherFor<MovieRejected>(),
            [nameof(PasswordResetRequested)] = PublisherFor<PasswordResetRequested>()
        };

        public static string NameOf(Type messageType)
            => Publishers.ContainsKey(messageType.Name)
                ? messageType.Name
                : throw new InvalidOperationException(
                    $"{messageType.Name} is not a registered outbox message type.");

        public static Task PublishAsync(string type, string payload, IBus bus, CancellationToken cancellationToken)
            => Publishers.TryGetValue(type, out var publisher)
                ? publisher(payload, bus, cancellationToken)
                : throw new InvalidOperationException($"'{type}' is not a registered outbox message type.");

        private static Func<string, IBus, CancellationToken, Task> PublisherFor<TMessage>()
            => (payload, bus, cancellationToken) => bus.PubSub.PublishAsync(
                JsonSerializer.Deserialize<TMessage>(payload, SerializerOptions)!,
                cancellationToken);
    }
}
