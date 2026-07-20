using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Model.Responses
{
    public class CastMemberResponse
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public int CountryId { get; set; }
        public DateTime? BirthDate { get; set; }
        public string? Biography { get; set; }
    }
}
