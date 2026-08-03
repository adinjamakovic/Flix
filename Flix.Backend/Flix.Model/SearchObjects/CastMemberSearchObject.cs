using Flix.Model.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Model.SearchObjects
{
    public class CastMemberSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public List<CastRole>? Roles { get; set; }
        public int? CountryId { get; set; }
        public int? MovieId { get; set; }
        public bool? IncludeCountry { get; set; }
        public bool? IncludeRoles { get; set; }
    }
}
