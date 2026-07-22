using System.Security.Cryptography;
using Flix.CommonServices.CryptoService;
using Flix.Model.Access;
using Flix.Model.Exceptions;
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
        private readonly ICryptoService _cryptoService;
        public UserService(
            FlixDbContext context,
            MapsterMapper.IMapper mapper,
            ICryptoService cryptoService,
            IValidator<UserInsertRequest> insertValidator,
            IValidator<UserUpdateRequest> updateValidator)
            : base(context, mapper, insertValidator, updateValidator)
        {
            _cryptoService = cryptoService;
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
                throw new ClientException($"Username '{request.Username}' is already taken.");

            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                throw new ClientException($"Email '{request.Email}' is already registered.");

            entity.PasswordSalt = _cryptoService.GenerateSalt();
            entity.PasswordHash = _cryptoService.GenerateHash(request.Password, entity.PasswordSalt);
        }

        public async Task<UserSensitiveResponse> GetByUsernameAsync(string username)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
            if(user is null)
                throw new ClientException($"User with username '{username}' not found.");
            var response = _mapper.Map<UserSensitiveResponse>(user);
            return response;
        }
    }
}
