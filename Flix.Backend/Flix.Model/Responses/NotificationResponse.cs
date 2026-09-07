using Flix.Model.Enums;

namespace Flix.Model.Responses
{
    public class NotificationResponse
    {
        public int Id {get; set;}
        public NotificationType Type {get; set;}
        public string Title {get; set;} = string.Empty;
        public string Message {get; set;} = string.Empty;
        public DateTime CreatedAt {get; set;}
        public DateTime? ReadAt {get; set;}
        public bool IsRead {get; set;}
        public int? MovieRequestId {get; set;}
        public int? MovieId {get; set;}
    }
}
