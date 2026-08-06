using Flix.Model.Enums;

namespace Flix.Model.Responses
{
    public class CastMemberResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public DateTime? BirthDate { get; set; }
        public string? Biography { get; set; }
        public string? Photo { get; set; }
        public CountryResponse? Country { get; set; }
        public List<CastRole> Roles { get; set; } = new List<CastRole>();
    }
}
