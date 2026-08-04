using System.Collections.Generic;
using System.Text;

namespace Flix.Model.Requests
{
    public class CastMemberUpdateRequest
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public int? CountryId { get; set; }
        public DateTime? BirthDate { get; set; }
        public string? Biography { get; set; }
    }
}
