using System.ComponentModel.DataAnnotations;

namespace Flix.Services.Database
{
    public class OutboxMessage
    {
        [Key]
        public int Id { get; set; }

        [MaxLength(100)]
        public string Type { get; set; } = string.Empty;
        public string Payload { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime NextAttemptAt { get; set; } = DateTime.UtcNow;
        public DateTime? ProcessedAt { get; set; }
        public int Attempts { get; set; }

        [MaxLength(1000)]
        public string? LastError { get; set; }
    }
}
