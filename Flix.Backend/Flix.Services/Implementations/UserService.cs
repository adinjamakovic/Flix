using Flix.CommonServices.CryptoService;
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
        }

        protected override async Task BeforeUpdateAsync(User entity, UserUpdateRequest request)
        {
            if (await _context.Users.AnyAsync(u => u.Username == request.Username && u.Id != entity.Id))
                throw new ClientException($"Username '{request.Username}' is already taken.");

            if (await _context.Users.AnyAsync(u => u.Email == request.Email && u.Id != entity.Id))
                throw new ClientException($"Email '{request.Email}' is already registered.");

            if(!_cryptoService.VerifyPassword(entity.PasswordHash, entity.PasswordSalt, request.Password!))
                entity.PasswordHash = _cryptoService.GenerateHash(request.Password!, entity.PasswordSalt);
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

            return _mapper.Map<UserResponse>(entity);
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

        public override async Task<UserResponse> InsertAsync(UserInsertRequest request)
        {
            await _insertValidator.ValidateAndThrowAsync(request);

            var entity = MapInsertRequestToEntity(request);
            await BeforeInsertAsync(entity, request);

            await _context.Users.AddAsync(entity);

            var role = new UserRole
            {
                User = entity,
                RoleId = 2,
                AssignedAt = DateTime.UtcNow
            };

            await _context.UserRoles.AddAsync(role);

            await _context.SaveChangesAsync();

            return _mapper.Map<UserResponse>(entity);
        }
    }
}
