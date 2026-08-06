using Flix.Model.Enums;

namespace Flix.Model.Requests
{
    public class MovieCreditRequest
    {
        public int CastMemberId { get; set; }
        public CastRole Role { get; set; }
        public string? CharacterName { get; set; }
        public int OrderOfAppearence { get; set; }
    }
}
