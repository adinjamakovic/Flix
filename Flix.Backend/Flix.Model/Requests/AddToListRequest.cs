using Flix.Model.Enums;

namespace Flix.Model.Requests
{
    public class AddToListRequest
    {
        public int MovieId {get; set;}

        // Only a custom list is picked by id, the watchlist is resolved from the caller.
        public int? ListId {get; set;}

        public ListType Type {get; set;} = ListType.Custom;
    }
}
