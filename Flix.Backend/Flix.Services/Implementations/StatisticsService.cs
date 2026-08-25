using Flix.Model.Enums;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public class StatisticsService : IStatisticsService
    {
        private readonly FlixDbContext _context;
        private readonly IActivityService _activityService;
        private readonly IMovieService _movieService;
        private readonly IUserService _userService;
        private readonly IGenreService _genreService;
        public StatisticsService(FlixDbContext context, IMovieService movieService, IUserService userService, IActivityService activityService, IGenreService genreService)
        {
            _context = context;
            _activityService = activityService;
            _movieService = movieService;
            _userService = userService;
            _genreService = genreService;
        }

        public async Task<AdminStatisticsResponse> GetStatistics()
        {
            var response = new AdminStatisticsResponse();

            var now = DateTime.UtcNow;
            var weekStart = now.AddDays(-7);
            var previousWeekStart = now.AddDays(-14);

            response.ActiveUsers = await _context.Users
                .Where(x => x.IsActive == true)
                .CountAsync();

            response.UserPercentage = CalculateTrend(
                await _context.Users.CountAsync(x => x.IsActive && x.CreatedAt >= weekStart),
                await _context.Users.CountAsync(x => x.IsActive && x.CreatedAt >= previousWeekStart && x.CreatedAt < weekStart));

            response.TotalClashes = await _context.Clashes
                .Where(x => x.Status != ClashStatus.Upcoming) // A Clash is counted only when its either active or completed, an upcoming clash does not have to be started
                .CountAsync();

            response.ClashPercentage = CalculateTrend(
                await _context.Clashes.CountAsync(x => x.Status != ClashStatus.Upcoming && x.CreatedAt >= weekStart),
                await _context.Clashes.CountAsync(x => x.Status != ClashStatus.Upcoming && x.CreatedAt >= previousWeekStart && x.CreatedAt < weekStart));

            response.TotalReviews = await _context.Reviews
                .CountAsync();

            response.ReviewPercentage = CalculateTrend(
                await _context.Reviews.CountAsync(x => x.CreatedAt >= weekStart),
                await _context.Reviews.CountAsync(x => x.CreatedAt >= previousWeekStart && x.CreatedAt < weekStart));

            response.TotalMovies = await _context.Movies
                .Where(x=>x.IsEnabled == true)
                .CountAsync();

            response.MoviePercentage = CalculateTrend(
                await _context.Movies.CountAsync(x => x.IsEnabled && x.CreatedAt >= weekStart),
                await _context.Movies.CountAsync(x => x.IsEnabled && x.CreatedAt >= previousWeekStart && x.CreatedAt < weekStart));

            response.MostActiveUsers = await _userService.GetMostActiveUsersAsync();

            response.MostPopularMovies = await _movieService.GetPopularMoviesAsync();

            response.RecentActivity = (await _activityService.GetAsync(new ActivitySearchObject
            {
                PageSize = 20,
                Page = 1,
                IncludeTotalCount = false
            })).Items;

            response.GenrePercentages = await _genreService.GetGenrePercentages();


            return response;
        }

        private static decimal CalculateTrend(int lastWeek, int weekBefore)
        {
            if (weekBefore == 0)
                return lastWeek == 0 ? 0m : 100m;

            return Math.Round((lastWeek - weekBefore) * 100m / weekBefore, 2);
        }
    }
}