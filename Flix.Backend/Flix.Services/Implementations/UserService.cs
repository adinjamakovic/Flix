using Flix.CommonServices.CryptoService;
using Flix.CommonServices.ImageStorageService;
using Flix.Model.Enums;
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
        // As many as the profile screen can comfortably show.
        private const int LatestReviewsOnProfile = 4;
        private const string WatchlistName = "Watchlist";
        private const int MostActiveUsersCount = 20;

        private readonly ICryptoService _cryptoService;
        private readonly IImageStorageService _imageStorageService;
        private readonly IResponseImageUrlResolver _imageUrlResolver;
        private readonly IActivityService _activityService;
        private readonly ICurrentUserService _currentUserService;
        public UserService(
            FlixDbContext context,
            MapsterMapper.IMapper mapper,
            ICryptoService cryptoService,
            IValidator<UserInsertRequest> insertValidator,
            IValidator<UserUpdateRequest> updateValidator,
            IImageStorageService imageStorageService,
            IResponseImageUrlResolver imageUrlResolver,
            IActivityService activityService,
            ICurrentUserService currentUserService)
            : base(context, mapper, insertValidator, updateValidator)
        {
            _cryptoService = cryptoService;
            _imageStorageService = imageStorageService;
            _imageUrlResolver = imageUrlResolver;
            _activityService = activityService;
            _currentUserService = currentUserService;
        }

        public override async Task<UserResponse> InsertAsync(UserInsertRequest request)
        {
            var response = await base.InsertAsync(request);

            await _activityService.InsertAsync(response.Id, new ActivityInsertRequest
            {
                Type = ActivityType.JoinedPlatform
            });

            return response;
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

            if (search?.IsActive is bool isActive)
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
                query = query.Include(u => u.Reviews)
                    .ThenInclude(x=>x.Movie);

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

            // Every account owns a watchlist from the moment it exists
            entity.Lists.Add(new MovieList
            {
                Name = WatchlistName,
                Type = ListType.Watchlist,
                CreatedAt = DateTime.UtcNow
            });
        }

        protected override void MapUpdateRequestToEntity(UserUpdateRequest request, User entity)
        {
            if (!_currentUserService.IsAdmin && entity.Id != _currentUserService.GetUserId())
                throw new ClientException("You can only edit your own account.");

            base.MapUpdateRequestToEntity(request, entity);
        }

        protected override async Task BeforeUpdateAsync(User entity, UserUpdateRequest request)
        {
            if (await _context.Users.AnyAsync(u => u.Username == request.Username && u.Id != entity.Id))
                throw new ClientException($"Username '{request.Username}' is already taken.");

            if (await _context.Users.AnyAsync(u => u.Email == request.Email && u.Id != entity.Id))
                throw new ClientException($"Email '{request.Email}' is already registered.");

            // An omitted password means "leave it alone" - only a supplied one that does not
            // already match is rehashed.
            if (!string.IsNullOrEmpty(request.Password))
            {
                VerifyOldPassword(entity, request);

                if (!_cryptoService.VerifyPassword(entity.PasswordHash, entity.PasswordSalt, request.Password))
                    entity.PasswordHash = _cryptoService.GenerateHash(request.Password, entity.PasswordSalt);
            }

            if (request.ProfileImage is not null)
                entity.ProfileImage = await _imageStorageService.ReplaceIfUploadedAsync(
                    ImageStorageCategory.User,
                    entity.ProfileImage,
                    request.ProfileImage);

            if (_currentUserService.IsAdmin)
                await AssignRoleAsync(entity, request.RoleId);
        }

        // An admin resetting someone's password has no way of knowing the old one; a user changing
        // their own has to prove they know it.
        private void VerifyOldPassword(User entity, UserUpdateRequest request)
        {
            if (_currentUserService.IsAdmin)
                return;

            if (string.IsNullOrEmpty(request.OldPassword))
                throw new ClientException("Your current password is required to set a new one.");

            if (!_cryptoService.VerifyPassword(entity.PasswordHash, entity.PasswordSalt, request.OldPassword))
                throw new ClientException("Your current password is incorrect.");
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
            var votes = await _context.ClashVotes
                .Where(x => x.VoterId == entity.Id)
                .ToListAsync();

            _context.ClashVotes.RemoveRange(votes);

            var followers = await _context.UserFollows
                .Where(x => x.FollowingId == entity.Id)
                .ToListAsync();

            _context.UserFollows.RemoveRange(followers);

            var blocks = await _context.UserBlocks
                .Where(x => x.BlockedId == entity.Id)
                .ToListAsync();

            _context.UserBlocks.RemoveRange(blocks);

            var reportsAgainstThem = await _context.UserReports
                .Where(x => x.ReportedUserId == entity.Id)
                .ToListAsync();

            _context.UserReports.RemoveRange(reportsAgainstThem);

            var mentions = await _context.Activities
                .Where(x => x.TargetUserId == entity.Id)
                .ToListAsync();

            _context.Activities.RemoveRange(mentions);

            await ClearModerationTrailAsync(entity.Id);
        }

        private async Task ClearModerationTrailAsync(int userId)
        {
            var handledUserReports = await _context.UserReports
                .Where(x => x.ReviewedByUserId == userId)
                .ToListAsync();

            foreach(var report in handledUserReports)
                report.ReviewedByUserId = null;

            var handledIssueReports = await _context.MovieIssueReports
                .Where(x => x.ReviewedByUserId == userId)
                .ToListAsync();

            foreach(var report in handledIssueReports)
                report.ReviewedByUserId = null;

            var handledRequests = await _context.MovieRequests
                .Where(x => x.ReviewedByUserId == userId)
                .ToListAsync();

            foreach(var request in handledRequests)
                request.ReviewedByUserId = null;
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
                .Include(x=>x.Reviews)
                .ThenInclude(x=>x.Movie)
                .Include(x => x.Followers)
                .Include(x => x.Following)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (entity is null)
                throw new ClientException($"{nameof(User)} with Id {id} not found.");

            var response = MapToResponse(entity);

            AttachLatestReviews(response, entity);

            return response;
        }

        // The profile screen shows the newest few reviews a user wrote. Mapster cannot do this leg of
        // the mapping - UserResponse.Reviews and ReviewResponse.User reference each other, so following
        // it recurses forever (see the User -> UserResponse config in Program.cs) - hence the by hand
        // mapping. The author is the profile being read, but it goes on every review anyway: a client
        // that opens one of these has the whole review without having to carry the profile into it.
        // It is mapped once rather than followed off each review, so the cycle cannot come back.
        private void AttachLatestReviews(UserResponse response, User entity)
        {
            var author = _mapper.Map<UserResponse>(entity);

            _imageUrlResolver.Resolve(author);

            response.Reviews = entity.Reviews
                .OrderByDescending(x => x.CreatedAt)
                .Take(LatestReviewsOnProfile)
                .Select(review =>
                {
                    var reviewResponse = _mapper.Map<ReviewResponse>(review);
                    reviewResponse.User = author;

                    _imageUrlResolver.Resolve(reviewResponse);

                    return reviewResponse;
                })
                .ToList();
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

        public async Task UpdateLastLoginAsync(int userId)
        {
            await _context.Users
                .Where(u => u.Id == userId)
                .ExecuteUpdateAsync(setters => setters.SetProperty(u => u.LastLoginAt, DateTime.UtcNow));
        }

        public async Task<List<UserResponse>> GetMostActiveUsersAsync()
        {
            var users = await GetDataSource()
                .Include(x => x.Country)
                .Include(x => x.Reviews)
                .Where(x => x.IsActive)
                .OrderByDescending(x => x.Reviews.Count())
                .Take(MostActiveUsersCount)
                .ToListAsync();

            return users.Select(MapToResponse).ToList();
        }
    }
}
