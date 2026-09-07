namespace Flix.Model.Responses
{
    public class MovieCreditResponse
    {
        public CastMemberResponse? CastMember { get; set; }
        public int Role { get; set; }
        public string? CharacterName { get; set; }
        public int OrderOfAppearence { get; set; }
    }
}
