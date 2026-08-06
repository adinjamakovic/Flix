using Flix.CommonServices.ImageStorageService;
using Flix.Model.Responses;
using Flix.Services.Interfaces;

namespace Flix.Services.Implementations
{
    // The image columns hold a blob path, which is nothing a client can load on its own, so every
    // response that carries an image has to be rewritten before it leaves the service.
    //
    // This lives in one place rather than in each service's MapToResponse because images also
    // arrive nested - a movie's country flag, a credit's cast photo, a review's author avatar -
    // and the service that owns the outer entity has no business knowing how to convert a path it
    // does not own. Adding an image to a response means adding it here, once, and every response
    // that embeds that type picks it up.
    public class ResponseImageUrlResolver : IResponseImageUrlResolver
    {
        private readonly IImageStorageService _imageStorageService;

        public ResponseImageUrlResolver(IImageStorageService imageStorageService)
        {
            _imageStorageService = imageStorageService;
        }

        public void Resolve(CastMemberResponse? response)
        {
            if (response is null)
                return;

            response.Photo = ToUrl(ImageStorageCategory.CastMember, response.Photo);
            Resolve(response.Country);
        }

        public void Resolve(ClashResponse? response)
        {
            if (response is null)
                return;

            response.BannerImage = ToUrl(ImageStorageCategory.Clash, response.BannerImage);
        }

        public void Resolve(ClashEntryResponse? response)
        {
            if (response is null)
                return;

            Resolve(response.User);
        }

        public void Resolve(CountryResponse? response)
        {
            if (response is null)
                return;

            response.FlagImage = ToUrl(ImageStorageCategory.Country, response.FlagImage);
        }

        public void Resolve(MovieResponse? response)
        {
            if (response is null)
                return;

            response.Poster = ToUrl(ImageStorageCategory.Movie, response.Poster);
            response.HeaderImage = ToUrl(ImageStorageCategory.Movie, response.HeaderImage);

            Resolve(response.Country);

            foreach (var director in response.Directors)
                Resolve(director);

            foreach (var credit in response.Cast)
                Resolve(credit);
        }

        public void Resolve(MovieCreditResponse? response)
        {
            if (response is null)
                return;

            Resolve(response.CastMember);
        }

        public void Resolve(ReviewResponse? response)
        {
            if (response is null)
                return;

            Resolve(response.User);
            Resolve(response.Movie);
        }

        public void Resolve(StudioResponse? response)
        {
            if (response is null)
                return;

            response.Logo = ToUrl(ImageStorageCategory.Studio, response.Logo);
        }

        public void Resolve(UserResponse? response)
        {
            if (response is null)
                return;

            response.ProfileImage = ToUrl(ImageStorageCategory.User, response.ProfileImage);
            Resolve(response.Country);
        }

        private string? ToUrl(ImageStorageCategory category, string? storedPath)
        {
            if (string.IsNullOrWhiteSpace(storedPath))
                return null;

            // A response that is reachable twice in one graph would otherwise be rewritten twice,
            // and the second pass would hand the finished URL back as if it were a blob path.
            if (Uri.IsWellFormedUriString(storedPath, UriKind.Absolute))
                return storedPath;

            return _imageStorageService.ToPublicPath(category, storedPath);
        }
    }
}
