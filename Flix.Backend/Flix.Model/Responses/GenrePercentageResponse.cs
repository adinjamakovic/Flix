namespace Flix.Model.Responses
{
    public class GenrePercentageResponse
    {
        public GenreResponse Genre { get; set; } = new();
        public decimal Percentage { get; set; }
    }
}
