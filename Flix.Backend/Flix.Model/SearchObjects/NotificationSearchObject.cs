using Flix.Model.Enums;

namespace Flix.Model.SearchObjects
{
    public class NotificationSearchObject : BaseSearchObject
    {
        public bool? IsRead {get; set;}
        public NotificationType? Type {get; set;}
    }
}
