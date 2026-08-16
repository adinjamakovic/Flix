using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Interfaces
{
    public interface IMovieService :
        IBaseCRUDService<MovieResponse, MovieSearchObject, MovieInsertRequest, MovieUpdateRequest>
    {
        public Task<PageResult<MovieResponse>> GetPopularMoviesForThisWeekAsync(int numberOfMovies);
        public Task<PageResult<MovieResponse>> GetPopularMoviesWithFriendsAsync(int userId);
    }
}
