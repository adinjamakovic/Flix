using System.Collections.Generic;
using System.Text;

namespace Flix.Model.SearchObjects
{
    public class BaseSearchObject
    {
        public int? Page { get; set; } = 1;
        public int? PageSize { get; set; } = 10;
        public bool? IncludeTotalCount { get; set; } = false;
    }
}
