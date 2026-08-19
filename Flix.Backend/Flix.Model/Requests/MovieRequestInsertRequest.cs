using Microsoft.AspNetCore.Http;

namespace Flix.Model.Requests
{
    public class MovieRequestInsertRequest
    {
        public string Title {get; set;} = string.Empty;
        public string? DirectorName {get; set;}
        public string? Description {get; set;}
        public DateTime? DateOfRelease {get; set;}
        public int GenreId {get; set;} = 0;
        public IFormFile? Poster {get; set;}
    }
}