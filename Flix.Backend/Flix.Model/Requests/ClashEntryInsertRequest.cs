namespace Flix.Model.Requests
{
    public class ClashEntryInsertRequest
    {
        // No need to send user id here.
        // User entering into a clash will be the currently logged in user.
        // Editing a clash entry is done through the Update method in ListService.cs
        public int ClashId {get; set;}
        public int MovieListId {get; set;}
    }
}