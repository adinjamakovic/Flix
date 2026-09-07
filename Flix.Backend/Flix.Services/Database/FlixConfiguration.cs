using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Database
{
    public partial class FlixDbContext : DbContext
    {
        protected void CreateConfiguration(ModelBuilder modelBuilder)
        {
            ConfigureMovieRelationships(modelBuilder);
            ConfigureUserRelationships(modelBuilder);
            ConfigureListRelationships(modelBuilder);
            ConfigureClashRelationships(modelBuilder);
            ConfigureActivityRelationships(modelBuilder);
            ConfigureReportRelationships(modelBuilder);
            ConfigureIndexes(modelBuilder);
        }

        private static void ConfigureMovieRelationships(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Movie>()
                .HasMany(m => m.Genres)
                .WithMany()
                .UsingEntity<MovieGenre>(
                    right => right.HasOne(mg => mg.Genre).WithMany().HasForeignKey(mg => mg.GenreId)
                        .OnDelete(DeleteBehavior.Cascade),
                    left => left.HasOne(mg => mg.Movie).WithMany().HasForeignKey(mg => mg.MovieId)
                        .OnDelete(DeleteBehavior.Cascade));

            modelBuilder.Entity<MovieCast>()
                .HasOne(mc => mc.Movie)
                .WithMany(m => m.Credits)
                .HasForeignKey(mc => mc.MovieId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovieCast>()
                .HasOne(mc => mc.CastMember)
                .WithMany(c => c.Credits)
                .HasForeignKey(mc => mc.CastMemberId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovieStudio>()
                .HasOne(ms => ms.Movie)
                .WithMany(m => m.Studios)
                .HasForeignKey(ms => ms.MovieId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovieStudio>()
                .HasOne(ms => ms.Studio)
                .WithMany(s => s.Movies)
                .HasForeignKey(ms => ms.StudioId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Movie>()
                .HasOne(m => m.Country)
                .WithMany(c => c.Movies)
                .HasForeignKey(m => m.CountryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Movie>()
                .HasOne(m => m.Language)
                .WithMany(l => l.Movies)
                .HasForeignKey(m => m.LanguageId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<CastMember>()
                .HasOne(c => c.Country)
                .WithMany()
                .HasForeignKey(c => c.CountryId)
                .OnDelete(DeleteBehavior.Restrict);
        }

        private static void ConfigureUserRelationships(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>()
                .HasOne(u => u.Country)
                .WithMany(c => c.Users)
                .HasForeignKey(u => u.CountryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<UserRole>()
                .HasOne(x => x.User)
                .WithMany(x => x.Roles)
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserRole>()
                .HasOne(x => x.Role)
                .WithMany(x => x.UserRoles)
                .HasForeignKey(x => x.RoleId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<RefreshToken>()
                .HasOne(t => t.User)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<ResetToken>()
                .HasOne(t => t.User)
                .WithMany(u => u.ResetTokens)
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Review>()
                .HasOne(r => r.User)
                .WithMany(u => u.Reviews)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Review>()
                .HasOne(r => r.Movie)
                .WithMany(m => m.Reviews)
                .HasForeignKey(r => r.MovieId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserFollow>()
                .HasOne(f => f.Follower)
                .WithMany(u => u.Following)
                .HasForeignKey(f => f.FollowerId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserFollow>()
                .HasOne(f => f.Followee)
                .WithMany(u => u.Followers)
                .HasForeignKey(f => f.FollowingId)
                .OnDelete(DeleteBehavior.ClientCascade);

            modelBuilder.Entity<UserBlock>()
                .HasOne(b => b.Blocker)
                .WithMany()
                .HasForeignKey(b => b.BlockerId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserBlock>()
                .HasOne(b => b.Blocked)
                .WithMany()
                .HasForeignKey(b => b.BlockedId)
                .OnDelete(DeleteBehavior.ClientCascade);
        }

        private static void ConfigureListRelationships(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<MovieList>()
                .HasOne(l => l.User)
                .WithMany(u => u.Lists)
                .HasForeignKey(l => l.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovieListItem>()
                .HasOne(i => i.MovieList)
                .WithMany(l => l.Items)
                .HasForeignKey(i => i.MovieListId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovieListItem>()
                .HasOne(i => i.Movie)
                .WithMany()
                .HasForeignKey(i => i.MovieId)
                .OnDelete(DeleteBehavior.Cascade);
        }

        private static void ConfigureClashRelationships(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<ClashEntry>()
                .HasOne(e => e.Clash)
                .WithMany(c => c.Entries)
                .HasForeignKey(e => e.ClashId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<ClashEntry>()
                .HasOne(e => e.MovieList)
                .WithMany()
                .HasForeignKey(e => e.MovieListId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<ClashEntry>()
                .HasOne(e => e.User)
                .WithMany(u => u.ClashEntries)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.ClientCascade);

            modelBuilder.Entity<ClashVote>()
                .HasOne(v => v.ClashEntry)
                .WithMany(e => e.Votes)
                .HasForeignKey(v => v.ClashEntryId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<ClashVote>()
                .HasOne(v => v.Voter)
                .WithMany()
                .HasForeignKey(v => v.VoterId)
                .OnDelete(DeleteBehavior.ClientCascade);
        }

        private static void ConfigureActivityRelationships(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Activity>()
                .HasOne(a => a.User)
                .WithMany()
                .HasForeignKey(a => a.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Activity>()
                .HasOne(a => a.Movie)
                .WithMany()
                .HasForeignKey(a => a.MovieId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Activity>()
                .HasOne(a => a.Clash)
                .WithMany()
                .HasForeignKey(a => a.ClashId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Activity>()
                .HasOne(a => a.Review)
                .WithMany()
                .HasForeignKey(a => a.ReviewId)
                .OnDelete(DeleteBehavior.ClientCascade);

            modelBuilder.Entity<Activity>()
                .HasOne(a => a.MovieList)
                .WithMany()
                .HasForeignKey(a => a.MovieListId)
                .OnDelete(DeleteBehavior.ClientCascade);

            modelBuilder.Entity<Activity>()
                .HasOne(a => a.TargetUser)
                .WithMany()
                .HasForeignKey(a => a.TargetUserId)
                .OnDelete(DeleteBehavior.ClientCascade);
        }

        private static void ConfigureReportRelationships(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<UserReport>()
                .HasOne(r => r.Reporter)
                .WithMany()
                .HasForeignKey(r => r.ReporterId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserReport>()
                .HasOne(r => r.ReportedUser)
                .WithMany()
                .HasForeignKey(r => r.ReportedUserId)
                .OnDelete(DeleteBehavior.ClientCascade);

            modelBuilder.Entity<UserReport>()
                .HasOne(r => r.ReviewedBy)
                .WithMany()
                .HasForeignKey(r => r.ReviewedByUserId)
                .OnDelete(DeleteBehavior.ClientSetNull);

            modelBuilder.Entity<MovieIssueReport>()
                .HasOne(r => r.ReportedBy)
                .WithMany()
                .HasForeignKey(r => r.ReportedByUserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovieIssueReport>()
                .HasOne(r => r.Movie)
                .WithMany()
                .HasForeignKey(r => r.MovieId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovieIssueReport>()
                .HasOne(r => r.ReviewedBy)
                .WithMany()
                .HasForeignKey(r => r.ReviewedByUserId)
                .OnDelete(DeleteBehavior.ClientSetNull);

            modelBuilder.Entity<MovieRequest>()
                .HasOne(r => r.RequestedBy)
                .WithMany()
                .HasForeignKey(r => r.RequestedByUserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovieRequest>()
                .HasOne(r => r.ReviewedBy)
                .WithMany()
                .HasForeignKey(r => r.ReviewedByUserId)
                .OnDelete(DeleteBehavior.ClientSetNull);

            modelBuilder.Entity<MovieRequest>()
                .HasOne(r => r.CreatedMovie)
                .WithMany()
                .HasForeignKey(r => r.CreatedMovieId)
                .OnDelete(DeleteBehavior.SetNull);
        }

        private static void ConfigureIndexes(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<Genre>()
                .HasIndex(g => g.Name)
                .IsUnique();

            modelBuilder.Entity<Role>()
                .HasIndex(r => r.Name)
                .IsUnique();

            modelBuilder.Entity<UserRole>()
                .HasIndex(ur => new { ur.UserId, ur.RoleId })
                .IsUnique();

            modelBuilder.Entity<MovieGenre>()
                .HasIndex(mg => new { mg.MovieId, mg.GenreId })
                .IsUnique();

            modelBuilder.Entity<MovieListItem>()
                .HasIndex(i => new { i.MovieListId, i.MovieId })
                .IsUnique();

            modelBuilder.Entity<UserFollow>()
                .HasIndex(f => new { f.FollowerId, f.FollowingId })
                .IsUnique();

            modelBuilder.Entity<UserBlock>()
                .HasIndex(b => new { b.BlockerId, b.BlockedId })
                .IsUnique();

            modelBuilder.Entity<ClashVote>()
                .HasIndex(v => new { v.VoterId, v.ClashEntryId })
                .IsUnique();
        }
    }
}
