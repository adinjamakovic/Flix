using Flix.Model.Exceptions;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public class RefreshTokenService : IRefreshTokenService
    {
        private readonly FlixDbContext _context;
        private readonly DbSet<RefreshToken> _refreshTokens;

        public RefreshTokenService(FlixDbContext context)
        {
            _context = context;
            _refreshTokens = _context.RefreshTokens;
        }

        public async Task<RefreshToken> GetStoredTokenAsync(string refreshToken)
        {
            var token = await _refreshTokens.FirstOrDefaultAsync(rt => rt.Token == refreshToken);
            if (token == null) 
                throw new ClientException("Refresh token not found.");
            return token;
        }

        public async Task InsertAsync(RefreshToken refreshToken)
        {
            await _refreshTokens.AddAsync(refreshToken);
            await _context.SaveChangesAsync();
        }

        // Revoking and issuing are one operation, so they share a single write rather than
        // leaving a window where the user has no valid refresh token at all.
        public async Task ReplaceUserRefreshTokensAsync(int userId, RefreshToken refreshToken)
        {
            _refreshTokens.RemoveRange(_refreshTokens.Where(rt => rt.UserId == userId));
            await _refreshTokens.AddAsync(refreshToken);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAllUserRefreshTokensAsync(int userId)
        {
            _refreshTokens.RemoveRange(_refreshTokens.Where(rt => rt.UserId == userId));
            await _context.SaveChangesAsync();
        }
    }
}
