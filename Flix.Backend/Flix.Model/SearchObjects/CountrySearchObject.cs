using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Model.SearchObjects
{
    public class CountrySearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? Code { get; set; }
    }
}
