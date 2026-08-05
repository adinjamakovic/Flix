using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using System.Text;

namespace Flix.Model.Requests
{
    public class CountryUpdateRequest
    {
        public string? Name { get; set; }
        public string? Code { get; set; }
        public IFormFile? FlagImage { get; set; }
    }
}
