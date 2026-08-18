using Flix.Model.Responses;

namespace Flix.Services.Interfaces
{
    // Rewrites the image fields of a response - and of everything nested inside it - from the
    // stored blob path to a URL the client can load. Implementations mutate the response in place.
    public interface IResponseImageUrlResolver
    {
        void Resolve(CastMemberResponse? response);
        void Resolve(ClashResponse? response);
        void Resolve(ClashEntryResponse? response);
        void Resolve(CountryResponse? response);
        void Resolve(ListResponse? response);
        void Resolve(MovieResponse? response);
        void Resolve(MovieCreditResponse? response);
        void Resolve(ReviewResponse? response);
        void Resolve(StudioResponse? response);
        void Resolve(UserResponse? response);
    }
}
