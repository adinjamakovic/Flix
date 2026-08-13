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
        public Task<List<MovieResponse>> GetPopularMoviesForThisWeekAsync(int numberOfMovies);
        public Task<List<MovieResponse>> GetPopularMoviesWithFriendsAsync(int userId);
    }
}
