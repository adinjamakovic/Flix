namespace Flix.Model.Responses
{
    public class StudioResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? Logo { get; set; }
    }
}
