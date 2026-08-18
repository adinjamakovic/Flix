using Flix.Model.Enums;

namespace Flix.Model.Responses
{
    public class ListResponse
    {
        public int Id {get; set;}
        public string Name {get; set;} = null!;
        public string? Description {get; set;} 
        public ListType Type {get; set;} = ListType.Custom;
        public DateTime CreatedAt {get; set;} = new DateTime(1900, 1, 1);
        public UserResponse? User {get; set;} 
        public List<MovieResponse>? Movies {get; set;}
        
    }
}