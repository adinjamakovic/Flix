using System.Collections.Generic;
using System.Text;

namespace Flix.Model.Responses
{
    public class PageResult<T>
    {
        public List<T> Items { get; set; } = new();
        public int? TotalCount { get; set; }
    }
}
