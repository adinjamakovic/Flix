using Flix.Model.Enums;
using System.Collections.Generic;
using System.Text;

namespace Flix.Model.Responses
{
    public class ClashResponse
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public string? BannerImage { get; set; }
        public ClashStatus? Status { get; set; }
        public int? Participants { get; set; }
        public DateTime? StartDate { get; set; } = DateTime.UtcNow;
        public DateTime? EndDate { get; set; } = DateTime.UtcNow;
        public DateTime? CreatedAt { get; set; } = DateTime.UtcNow;

    }
}
