using Flix.CommonServices.CryptoService;
using Flix.CommonServices.ImageStorageService;
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
        private const int DefaultRoleId = 2;

        private readonly ICryptoService _cryptoService;
        private readonly IImageStorageService _imageStorageService;
        private readonly IResponseImageUrlResolver _imageUrlResolver;
        public UserService(
            FlixDbContext context,
            MapsterMapper.IMapper mapper,
            ICryptoService cryptoService,
            IValidator<UserInsertRequest> insertValidator,
            IValidator<UserUpdateRequest> updateValidator,
            IImageStorageService imageStorageService,
            IResponseImageUrlResolver imageUrlResolver)
            : base(context, mapper, insertValidator, updateValidator)
        {
            _cryptoService = cryptoService;
            _imageStorageService = imageStorageService;
            _imageUrlResolver = imageUrlResolver;
        }

        protected override IQueryable<User> GetDataSource()
            => _context.Set<User>()
                .OrderBy(u => u.Id)
                .AsSplitQuery();

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

            if(search?.CountryId is int countryId)
                query = query.Where(u => u.CountryId == countryId);

            if (search.IsActive is bool isActive)
                query = query.Where(u => u.IsActive == isActive);

            return query;
        }

        protected override Task<IQueryable<User>> IncludeRelatedEntities(UserSearchObject? search, IQueryable<User> query)
        {
            if(search?.IncludeCountry == true)
                query = query.Include(u => u.Country);

            if(search?.IncludeRole == true)
                query = query.Include(u => u.Roles)
                    .ThenInclude(ur => ur.Role);

            if(search?.IncludeReviews == true)
                query = query.Include(u => u.Reviews);

            return base.IncludeRelatedEntities(search, query);
        }

        protected override async Task BeforeInsertAsync(User entity, UserInsertRequest request)
        {
            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
                throw new ClientException($"Username '{request.Username}' is already taken.");

            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                throw new ClientException($"Email '{request.Email}' is already registered.");

            entity.PasswordSalt = _cryptoService.GenerateSalt();
            entity.PasswordHash = _cryptoService.GenerateHash(request.Password, entity.PasswordSalt);

            entity.ProfileImage = await _imageStorageService.SaveAsync(ImageStorageCategory.User, request.ProfileImage);

            entity.Roles.Add(new UserRole
            {
                Role = await GetAssignableRoleAsync(request.RoleId ?? DefaultRoleId),
                AssignedAt = DateTime.UtcNow
            });
        }

        protected override async Task BeforeUpdateAsync(User entity, UserUpdateRequest request)
        {
            if (await _context.Users.AnyAsync(u => u.Username == request.Username && u.Id != entity.Id))
                throw new ClientException($"Username '{request.Username}' is already taken.");

            if (await _context.Users.AnyAsync(u => u.Email == request.Email && u.Id != entity.Id))
                throw new ClientException($"Email '{request.Email}' is already registered.");

            // An omitted password means "leave it alone" - only a supplied one that does not
            // already match is rehashed.
            if (!string.IsNullOrEmpty(request.Password)
                && !_cryptoService.VerifyPassword(entity.PasswordHash, entity.PasswordSalt, request.Password))
                entity.PasswordHash = _cryptoService.GenerateHash(request.Password, entity.PasswordSalt);

            if (request.ProfileImage is not null)
                entity.ProfileImage = await _imageStorageService.ReplaceIfUploadedAsync(
                    ImageStorageCategory.User,
                    entity.ProfileImage,
                    request.ProfileImage);

            await AssignRoleAsync(entity, request.RoleId);
        }

        private async Task AssignRoleAsync(User entity, int? roleId)
        {
            if (roleId is not int id)
                return;

            var role = await GetAssignableRoleAsync(id);

            await _context.Entry(entity)
                .Collection(u => u.Roles)
                .Query()
                .Include(ur => ur.Role)
                .LoadAsync();

            if (entity.Roles.Any(ur => ur.RoleId == id))
                return;

            _context.UserRoles.RemoveRange(entity.Roles);
            entity.Roles.Clear();
            entity.Roles.Add(new UserRole { Role = role, AssignedAt = DateTime.UtcNow });
        }

        private async Task<Role> GetAssignableRoleAsync(int roleId)
        {
            return await _context.Roles.FirstOrDefaultAsync(r => r.Id == roleId && r.IsActive)
                ?? throw new ClientException($"Role with Id {roleId} does not exist or is not active.");
        }

        protected override async Task BeforeDeleteAsync(User entity)
        {
            await _context.Entry(entity)
                .Collection(u => u.Roles)
                .LoadAsync();
            _context.UserRoles.RemoveRange(entity.Roles);

            await _context.Entry(entity)
                .Collection(u => u.RefreshTokens)
                .LoadAsync();
            _context.RefreshTokens.RemoveRange(entity.RefreshTokens);
        }

        protected override async Task AfterDeleteAsync(User entity)
        {
            await _imageStorageService.DeleteIfExistsAsync(ImageStorageCategory.User, entity.ProfileImage);
        }

        protected override UserResponse MapToResponse(User entity)
        {
            var response = base.MapToResponse(entity);

            _imageUrlResolver.Resolve(response);

            return response;
        }

        public override async Task<UserResponse> GetByIdAsync(int id)
        {
            var entity = await GetDataSource()
                .Include(x => x.Country)
                .Include(x => x.Roles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (entity is null)
                throw new ClientException($"{nameof(User)} with Id {id} not found.");

            return MapToResponse(entity);
        }

        public async Task<UserSensitiveResponse?> GetByUsernameAsync(string username)
        {
            var user = await GetDataSource()
                .Include(u => u.Roles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Username == username);
            var response = user == null ? null : _mapper.Map<UserSensitiveResponse>(user);
            return response;
        }

    }
}
