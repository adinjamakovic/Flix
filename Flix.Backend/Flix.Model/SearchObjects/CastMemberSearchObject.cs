using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Model.SearchObjects
{
    public class CastMemberSearchObject : BaseSearchObject
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public int? CountryId { get; set; } 
        public int? MovieId { get; set; }
    }
}
