using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;

namespace Flix.Services.Interfaces
{
    public interface IMovieService :
        IBaseCRUDService<MovieResponse, MovieSearchObject, MovieInsertRequest, MovieUpdateRequest>
    {
        Task<PageResult<MovieResponse>> GetPopularMoviesForThisWeekAsync(int numberOfMovies);
        Task<PageResult<MovieResponse>> GetPopularMoviesWithFriendsAsync(int userId);
        Task<List<MovieResponse>> GetPopularMoviesAsync();
    }
}
