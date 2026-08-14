using Microsoft.AspNetCore.Http;

namespace Flix.Model.Requests
{
    public class MovieRequestUpdateRequest : MovieUpdateRequest
    {
        public bool IsApproved {get; set;} = false; 
    }
}