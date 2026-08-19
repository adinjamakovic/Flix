namespace Flix.Model.Requests
{
    public class ListInsertRequest
    {
        public required string Name {get; set;}
        public string? Description {get; set;}
        // Integer list of movie identifiers
        // Can be null, user can opt to not add movies during 
        // creation of list
        public List<int> MovieIds {get; set;} = new List<int>();
    }
}