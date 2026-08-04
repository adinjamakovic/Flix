using System.Linq;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Database
{
    public partial class FlixDbContext : DbContext
    {
        public FlixDbContext(DbContextOptions<FlixDbContext> options) : base(options)
        {
        }
        public DbSet<Movie> Movies => Set<Movie>();
        public DbSet<Genre> Genres => Set<Genre>();
        public DbSet<MovieGenre> MovieGenres => Set<MovieGenre>();
        public DbSet<Country> Countries => Set<Country>();
        public DbSet<Language> Languages => Set<Language>();
        public DbSet<CastMember> CastMembers => Set<CastMember>();
        public DbSet<MovieCast> MovieCasts => Set<MovieCast>();
        public DbSet<User> Users => Set<User>();
        public DbSet<Role> Roles => Set<Role>();
        public DbSet<UserRole> UserRoles => Set<UserRole>();
        public DbSet<UserFollow> UserFollows => Set<UserFollow>();
        public DbSet<UserBlock> UserBlocks => Set<UserBlock>();
        public DbSet<Review> Reviews => Set<Review>();
        public DbSet<Activity> Activities => Set<Activity>();
        public DbSet<MovieList> MovieLists => Set<MovieList>();
        public DbSet<MovieListItem> MovieListItems => Set<MovieListItem>();
        public DbSet<Clash> Clashes => Set<Clash>();
        public DbSet<ClashEntry> ClashEntries => Set<ClashEntry>();
        public DbSet<ClashVote> ClashVotes => Set<ClashVote>();
        public DbSet<MovieRequest> MovieRequests => Set<MovieRequest>();
        public DbSet<MovieIssueReport> MovieIssueReports => Set<MovieIssueReport>();
        public DbSet<UserReport> UserReports => Set<UserReport>();
        public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            CreateConfiguration(modelBuilder);

            SeedData(modelBuilder);
        }
    }
}
