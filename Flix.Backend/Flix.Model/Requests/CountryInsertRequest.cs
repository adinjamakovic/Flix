using Microsoft.AspNetCore.Http;

namespace Flix.Model.Requests
{
    public class CountryInsertRequest
    {
        public string Name { get; set; } = string.Empty;
        public string? Code { get; set; }
        public IFormFile? FlagImage { get; set; }
    }
}
