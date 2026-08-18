namespace Flix.Model.Requests
{
    public class ListUpdateRequest
    {
        public required string Name {get; set;}
        public string? Description {get; set;}
        // Same rule as ListInsertRequest
        // User modifies current movies in list
        public List<int> MovieIds {get; set;} = new List<int>();
    }
}