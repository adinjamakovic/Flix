namespace Flix.Model.SearchObjects
{
    public class BaseSearchObject
    {
        public const int DefaultPage = 1;
        public const int DefaultPageSize = 10;
        public const int MaxPageSize = 100;

        private int _page = DefaultPage;
        private int _pageSize = DefaultPageSize;

        // Clamped rather than rejected: an out-of-range page size is capped so a client
        // asking for more than MaxPageSize still gets a response, never the whole table.
        public int Page
        {
            get => _page;
            set => _page = value < 1 ? DefaultPage : value;
        }

        public int PageSize
        {
            get => _pageSize;
            set => _pageSize = Math.Clamp(value, 1, MaxPageSize);
        }

        public bool? IncludeTotalCount { get; set; } = false;
    }
}
