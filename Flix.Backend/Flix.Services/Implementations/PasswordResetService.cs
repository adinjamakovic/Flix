using System.Security.Cryptography;
using Flix.CommonServices.CryptoService;
using Flix.Model.Access;
using Flix.Model.Exceptions;
using Flix.Model.Messages;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public class PasswordResetService : IPasswordResetService
    {
        private const int TokenLifetimeInMinutes = 15;
        private const int MaxAttempts = 5;
        private readonly FlixDbContext _context;
        private readonly ICryptoService _cryptoService;
        private readonly IRefreshTokenService _refreshTokenService;
        private readonly IOutboxService _outboxService;
        private readonly IValidator<ResetPasswordRequest> _resetValidator;

        public PasswordResetService(
            FlixDbContext context,
            ICryptoService cryptoService,
            IRefreshTokenService refreshTokenService,
            IOutboxService outboxService,
            IValidator<ResetPasswordRequest> resetValidator)
        {
            _context = context;
            _cryptoService = cryptoService;
            _refreshTokenService = refreshTokenService;
            _outboxService = outboxService;
            _resetValidator = resetValidator;
        }

        public async Task RequestResetAsync(ForgotPasswordRequest request)
        {
            var email = request.Email?.Trim() ?? string.Empty;

            if (email.Length == 0)
                return;

            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.Email == email && x.IsActive);

            if (user is null)
                return;

            await InvalidateOutstandingTokensAsync(user.Id);

            var token = GenerateToken();
            var salt = _cryptoService.GenerateSalt();

            var entity = new ResetToken
            {
                UserId = user.Id,
                TokenHash = _cryptoService.GenerateHash(token, salt),
                TokenSalt = salt,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddMinutes(TokenLifetimeInMinutes)
            };

            _context.ResetTokens.Add(entity);

            await using var transaction = await _context.Database.BeginTransactionAsync();

            await _context.SaveChangesAsync();

            _outboxService.Enqueue(new PasswordResetRequested
            {
                Id = entity.Id,
                Data = new PasswordResetData
                {
                    UserId = user.Id,
                    Token = token,
                    ExpiresAt = entity.ExpiresAt
                }
            });

            await _context.SaveChangesAsync();

            await transaction.CommitAsync();
        }

        public async Task VerifyTokenAsync(VerifyResetTokenRequest request)
        {
            await ResolveTokenAsync(request.Email, request.Token);
        }

        public async Task ResetPasswordAsync(ResetPasswordRequest request)
        {
            await _resetValidator.ValidateAndThrowAsync(request);

            var (user, token) = await ResolveTokenAsync(request.Email, request.Token);

            user.PasswordSalt = _cryptoService.GenerateSalt();
            user.PasswordHash = _cryptoService.GenerateHash(request.NewPassword, user.PasswordSalt);

            token.UsedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            await _refreshTokenService.DeleteAllUserRefreshTokensAsync(user.Id);
        }

        private async Task<(User User, ResetToken Token)> ResolveTokenAsync(string? email, string? token)
        {
            var trimmedEmail = email?.Trim() ?? string.Empty;
            var trimmedToken = token?.Trim() ?? string.Empty;

            var user = trimmedEmail.Length == 0
                ? null
                : await _context.Users.FirstOrDefaultAsync(x => x.Email == trimmedEmail && x.IsActive);

            if (user is null || trimmedToken.Length == 0)
                throw InvalidToken();

            var candidates = await _context.ResetTokens
                .Where(x => x.UserId == user.Id
                    && x.UsedAt == null
                    && x.ExpiresAt > DateTime.UtcNow
                    && x.Attempts < MaxAttempts)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            var match = candidates.FirstOrDefault(x =>
                _cryptoService.VerifyPassword(x.TokenHash, x.TokenSalt, trimmedToken));

            if (match is null)
            {
                foreach (var candidate in candidates)
                    candidate.Attempts++;

                await _context.SaveChangesAsync();

                throw InvalidToken();
            }

            return (user, match);
        }

        private async Task InvalidateOutstandingTokensAsync(int userId)
        {
            var outstanding = await _context.ResetTokens
                .Where(x => x.UserId == userId && x.UsedAt == null)
                .ToListAsync();

            _context.ResetTokens.RemoveRange(outstanding);
        }

        private static ClientException InvalidToken()
            => new("The reset code is invalid or has expired. Request a new one.");

        private static string GenerateToken()
            => RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");
    }
}
