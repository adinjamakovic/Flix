using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IGenreService :
        IBaseCRUDService<GenreResponse, GenreSearchObject, GenreInsertRequest, GenreUpdateRequest>
    {
        Task<List<GenrePercentageResponse>> GetGenrePercentages();
    }
}
