using Flix.Services.Database;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Interfaces
{
    public interface IRefreshTokenService
    {
        Task<RefreshToken> GetStoredTokenAsync(string refreshToken);
        Task InsertAsync(RefreshToken refreshToken);
        Task ReplaceUserRefreshTokensAsync(int userId, RefreshToken refreshToken);
        Task DeleteAllUserRefreshTokensAsync(int userId);
    }
}
