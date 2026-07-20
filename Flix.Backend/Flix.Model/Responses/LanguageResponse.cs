using System;
using System.Collections.Generic;
using System.Text;

namespace Flix.Model.Responses
{
    public class LanguageResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Code { get; set; }
    }
}
