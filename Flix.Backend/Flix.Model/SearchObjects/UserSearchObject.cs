using System.Diagnostics.Contracts;

namespace Flix.Model.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Username { get; set; }
        public int? CountryId { get; set; }
        public bool? IsActive { get; set; }
        public bool? IncludeCountry {get; set;}
        public bool? IncludeRole {get; set;}
        public bool? IncludeReviews { get; set; }
    }
}
