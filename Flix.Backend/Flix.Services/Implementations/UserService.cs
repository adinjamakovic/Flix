using System.Security.Cryptography;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public class UserService
        : BaseCRUDService<User, UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        public UserService(
            FlixDbContext context,
            MapsterMapper.IMapper mapper,
            IValidator<UserInsertRequest> insertValidator,
            IValidator<UserUpdateRequest> updateValidator)
            : base(context, mapper, insertValidator, updateValidator)
        {
        }

        protected override IQueryable<User> ApplyFilters(IQueryable<User> query, UserSearchObject? search)
        {
            if (search is null)
                return query;

            if (!string.IsNullOrWhiteSpace(search.FirstName?.Trim()))
                query = query.Where(u => u.FirstName.Contains(search.FirstName));

            if (!string.IsNullOrWhiteSpace(search.LastName?.Trim()))
                query = query.Where(u => u.LastName.Contains(search.LastName));

            if (!string.IsNullOrWhiteSpace(search.Email?.Trim()))
                query = query.Where(u => u.Email.Contains(search.Email));

            if (!string.IsNullOrWhiteSpace(search.Username?.Trim()))
                query = query.Where(u => u.Username.Contains(search.Username));

            if (search.IsActive is bool isActive)
                query = query.Where(u => u.IsActive == isActive);

            return query;
        }

        protected override async Task BeforeInsertAsync(User entity, UserInsertRequest request)
        {
            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
                throw new InvalidOperationException($"Username '{request.Username}' is already taken.");

            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                throw new InvalidOperationException($"Email '{request.Email}' is already registered.");

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = HashPassword(request.Password, entity.PasswordSalt);
        }

        private static string GenerateSalt()
        {
            return Convert.ToBase64String(RandomNumberGenerator.GetBytes(16));
        }

        private static string HashPassword(string password, string salt)
        {
            byte[] hash = Rfc2898DeriveBytes.Pbkdf2(
                password,
                Convert.FromBase64String(salt),
                iterations: 100000,
                HashAlgorithmName.SHA256,
                outputLength: 32);

            return Convert.ToBase64String(hash);
        }
    }
}
