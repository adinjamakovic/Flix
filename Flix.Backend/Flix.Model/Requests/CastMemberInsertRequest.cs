using Microsoft.AspNetCore.Http;

namespace Flix.Model.Requests
{
    public class CastMemberInsertRequest
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public int CountryId { get; set; }
        public DateTime? BirthDate { get; set; }
        public string? Biography { get; set; }
        public IFormFile? Photo { get; set; }
    }
}
