using Flix.Model.Responses;

namespace Flix.Model.Messages
{
    public class MovieRejected
    {
        public int Id {get; set;}
        public MovieRequestResponse? Data {get; set;}
    }
}
