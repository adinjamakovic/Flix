using System.Text.Json;
using Flix.Services.Database;
using Flix.Services.Interfaces;

namespace Flix.Services.Implementations
{
    public class OutboxService : IOutboxService
    {
        private readonly FlixDbContext _context;

        public OutboxService(FlixDbContext context)
        {
            _context = context;
        }

        // Deliberately does not save: the row has to be written by the caller's own
        // SaveChanges, inside the caller's transaction, or the event is no longer tied
        // to the business change it announces.
        public void Enqueue(object message)
        {
            var type = message.GetType();

            _context.OutboxMessages.Add(new OutboxMessage
            {
                Type = OutboxMessageRegistry.NameOf(type),
                Payload = JsonSerializer.Serialize(message, type, OutboxMessageRegistry.SerializerOptions),
                CreatedAt = DateTime.UtcNow,
                NextAttemptAt = DateTime.UtcNow
            });
        }
    }
}
