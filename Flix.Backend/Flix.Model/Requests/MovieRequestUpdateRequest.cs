using Microsoft.AspNetCore.Http;

namespace Flix.Model.Requests
{
    public class MovieRequestUpdateRequest : MovieUpdateRequest
    {
        public bool IsApproved {get; set;} = false;
        public string? DirectorFirstName {get; set;}
        public string? DirectorLastName {get; set;}
        public int? DirectorCountryId {get; set;}
        public DateTime? DirectorBirthDate {get; set;}
        public string? DirectorBiography {get; set;}
        public IFormFile? DirectorPhoto {get; set;}
    }
}
