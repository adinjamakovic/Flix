using Flix.CommonServices.CryptoService;
using Flix.Model.Access;
using Flix.Model.Responses;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace Flix.WebApi.Services.AccessManager
{
    public class AccessManager : IAccessManager
    {
        private readonly IUserService _userService;
        private readonly IRefreshTokenService _refreshTokenService;
        private readonly IConfiguration _configuration;
        private readonly ICryptoService _cryptoService;
        public AccessManager(
            IUserService userService,
            IRefreshTokenService refreshTokenService,
            IConfiguration configuration,
            ICryptoService cryptoService)
        {
            _userService = userService;
            _refreshTokenService = refreshTokenService;
            _configuration = configuration;
            _cryptoService = cryptoService;
        }
        public async Task<UserLoginResponse> LoginAsync(UserLoginRequest request)
        {
            var user = await _userService.GetByUsernameAsync(request.Username);

            if (user is null)
                throw new Exception($"User with username '{request.Username}' not found.");

            var isPasswordValid = _cryptoService.VerifyPassword(user.PasswordHash, user.PasswordSalt, request.Password);
            if (!isPasswordValid)
                throw new Exception("Invalid credentials");

            var accessToken = GenerateToken(user);
            var refreshTokenValue = GenerateRefreshToken();

            var refreshToken = new RefreshToken
            {
                UserId = user.Id,
                Token = refreshTokenValue,
                ExpiresAt = DateTime.UtcNow.AddDays(7)
            };

            await _refreshTokenService.InsertAsync(refreshToken);

            return new UserLoginResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshTokenValue
            };
        }

        public async Task<UserLoginResponse> LoginWithRefreshTokenAsync(RefreshAccessTokenRequest request)
        {
            if (string.IsNullOrEmpty(request.RefreshToken))
                throw new ArgumentException("Refresh token is required.");

            var refreshToken = await _refreshTokenService.GetStoredTokenAsync(request.RefreshToken);

            if (refreshToken == null)
                throw new Exception("Invalid refresh token.");

            if (refreshToken.ExpiresAt < DateTime.UtcNow)
                throw new Exception("Refresh token has expired.");

            var user = await _userService.GetByIdAsync(refreshToken.UserId);

            if (user == null)
                throw new Exception("User not found");

            if (!user.IsActive)
                throw new Exception("User is not active");

            await _refreshTokenService.DeleteAllUserRefreshTokensAsync(user.Id);

            var accessToken = GenerateToken(user);
            var refreshTokenValue = GenerateRefreshToken();
            
            var token = new RefreshToken
            {
                UserId = user.Id,
                Token = refreshTokenValue,
                ExpiresAt = DateTime.UtcNow.AddDays(7)
            };

            await _refreshTokenService.InsertAsync(token);
            return new UserLoginResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshTokenValue
            };
        }

        private string GenerateToken(UserResponse user)
        {
            string secretKeyString = _configuration["JwtToken:SecretKey"] ?? string.Empty;
            string issuer = _configuration["JwtToken:Issuer"] ?? "https://flix.com";
            string audience = _configuration["JwtToken:Audience"] ?? "http://flix.com";
            string duration = _configuration["JwtToken:DurationInMinutes"] ?? "1";

            var secretKey = Encoding.ASCII.GetBytes(secretKeyString);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimNames.Id, user.Id.ToString()),
                    new Claim(ClaimNames.Username, user.Username),
                    new Claim(ClaimNames.Email, user.Email),
                    new Claim(ClaimNames.FirstName, user.FirstName),
                    new Claim(ClaimNames.LastName, user.LastName),
                    new Claim(ClaimNames.IsActive, user.IsActive.ToString())
                }),
                Expires = DateTime.UtcNow.AddMinutes(double.Parse(duration)),
                Issuer = issuer,
                Audience = audience,
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(secretKey), SecurityAlgorithms.HmacSha256Signature)
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);

            return tokenHandler.WriteToken(token);
        }

        private static string GenerateRefreshToken()
        {
            var randomBytes = RandomNumberGenerator.GetBytes(64);
            return Convert.ToBase64String(randomBytes);
        }

        
    }
}
