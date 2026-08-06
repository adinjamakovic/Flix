using Microsoft.AspNetCore.Http;

namespace Flix.Model.Requests
{
    public class ClashUpdateRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime StartDate { get; set; } = DateTime.UtcNow.AddDays(3);
        public DateTime EndDate { get; set; } = DateTime.UtcNow.AddDays(7);
        public IFormFile? BannerImage { get; set; }
    }
}
