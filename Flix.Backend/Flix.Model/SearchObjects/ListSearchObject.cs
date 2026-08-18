using System.ComponentModel;
using Flix.Model.Enums;

namespace Flix.Model.SearchObjects
{
    public class ListSearchObject : BaseSearchObject
    {
        public string? Name {get; set;}
        public ListType? Type {get; set;}
        public int? UserId {get; set;}
        public bool? IncludeUser {get; set;}
        public bool? IncludeMovies {get; set;}
    }
}