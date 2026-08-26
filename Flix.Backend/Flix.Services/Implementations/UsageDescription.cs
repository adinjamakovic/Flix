namespace Flix.Services.Implementations
{
    public static class UsageDescription
    {
        public static string? Describe(params (int Count, string Noun)[] parts)
        {
            var used = parts
                .Where(x => x.Count > 0)
                .Select(x => $"{x.Count} {x.Noun}{(x.Count == 1 ? string.Empty : "s")}")
                .ToList();

            return used.Count switch
            {
                0 => null,
                1 => used[0],
                _ => $"{string.Join(", ", used.Take(used.Count - 1))} and {used[^1]}"
            };
        }
    }
}
