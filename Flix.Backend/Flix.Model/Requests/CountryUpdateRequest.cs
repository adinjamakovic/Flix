using Microsoft.AspNetCore.Http;

namespace Flix.Model.Requests
{
    public class CountryUpdateRequest
    {
        public string? Name { get; set; }
        public string? Code { get; set; }
        public IFormFile? FlagImage { get; set; }
    }
}
