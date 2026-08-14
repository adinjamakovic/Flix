using Flix.Model.Enums;

namespace Flix.Model.Responses
{
    public class MovieRequestResponse
    {
        public int Id {get; set;}
        public UserResponse? RequestedByUser {get; set;}
        public MovieResponse? Movie {get; set;}
        public MovieRequestStatus Status {get; set;}
        public DateTime CreatedAt {get; set;}
    }
}