using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace Flix.Services.Database
{
    /// <summary>
    /// Entity Framework Core context for the Flix database. Exposes every entity
    /// and configures the relationships, join tables and unique constraints that
    /// cannot be expressed with data annotations alone.
    /// </summary>
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
