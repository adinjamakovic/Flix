using System.Linq;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace Flix.Services.Database
{
    public partial class FlixDbContext : DbContext
    {
        protected void CreateConfiguration(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Movie>()
                .HasMany(m => m.Genres)
                .WithMany()
                .UsingEntity<MovieGenre>(
                    right => right.HasOne(mg => mg.Genre).WithMany().HasForeignKey(mg => mg.GenreId),
                    left => left.HasOne(mg => mg.Movie).WithMany().HasForeignKey(mg => mg.MovieId));

            modelBuilder.Entity<MovieRecommendation>()
                .HasOne(x=>x.Movie)
                .WithMany()
                .HasForeignKey(x=>x.MovieId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<MovieRecommendation>()
                .HasOne(x=>x.RecommendedMovie)
                .WithMany()
                .HasForeignKey(x=>x.RecommendedMovieId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<UserRole>()
                .HasOne(x => x.User)
                .WithMany(x=>x.Roles)
                .HasForeignKey(x=>x.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<UserRole>()
                .HasOne(x => x.Role)
                .WithMany(x=>x.UserRoles)
                .HasForeignKey(x=>x.RoleId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<UserFollow>()
                .HasOne(f => f.Follower)
                .WithMany(u => u.Following)
                .HasForeignKey(f => f.FollowerId);

            modelBuilder.Entity<UserFollow>()
                .HasOne(f => f.Followee)
                .WithMany(u => u.Followers)
                .HasForeignKey(f => f.FollowingId);

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

            foreach (IMutableForeignKey fk in modelBuilder.Model.GetEntityTypes()
                         .SelectMany(t => t.GetForeignKeys()))
            {
                fk.DeleteBehavior = DeleteBehavior.Restrict;
            }
        }
    }
}
