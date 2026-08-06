using Microsoft.AspNetCore.Http;

namespace Flix.Model.Requests
{
    public class StudioUpdateRequest
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public IFormFile? Logo { get; set; }
    }
}
