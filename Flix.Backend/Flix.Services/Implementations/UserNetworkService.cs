using Flix.Model.Enums;
using Flix.Model.Exceptions;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public class UserNetworkService(
        FlixDbContext context,
        IMapper mapper,
        ICurrentUserService currentUserService,
        IResponseImageUrlResolver imageUrlResolver,
        IActivityService activityService,
        IValidator<UserReportInsertRequest> reportValidator) : IUserNetworkService
    {
        private readonly FlixDbContext _context = context;
        private readonly IMapper _mapper = mapper;
        private readonly ICurrentUserService _currentUserService = currentUserService;
        private readonly IResponseImageUrlResolver _imageUrlResolver = imageUrlResolver;
        private readonly IActivityService _activityService = activityService;
        private readonly IValidator<UserReportInsertRequest> _reportValidator = reportValidator;

        public async Task<PageResult<UserResponse>> GetFollowersAsync(int userId, BaseSearchObject? search = null)
        {
            await EnsureUserExistsAsync(userId);

            return await GetPagedAsync(
                _context.UserFollows
                    .Where(x => x.FollowingId == userId)
                    .OrderBy(x => x.Follower.Username)
                    .Select(x => x.Follower),
                search);
        }

        public async Task<PageResult<UserResponse>> GetFollowingAsync(int userId, BaseSearchObject? search = null)
        {
            await EnsureUserExistsAsync(userId);

            return await GetPagedAsync(
                _context.UserFollows
                    .Where(x => x.FollowerId == userId)
                    .OrderBy(x => x.Followee.Username)
                    .Select(x => x.Followee),
                search);
        }

        public Task<PageResult<UserResponse>> GetBlockedAsync(BaseSearchObject? search = null)
        {
            var currentUserId = _currentUserService.GetUserId();

            return GetPagedAsync(
                _context.UserBlocks
                    .Where(x => x.BlockerId == currentUserId)
                    .OrderBy(x => x.Blocked.Username)
                    .Select(x => x.Blocked),
                search);
        }

        public async Task<UserRelationshipResponse> GetRelationshipAsync(int userId)
        {
            await EnsureUserExistsAsync(userId);

            return await BuildRelationshipAsync(userId);
        }

        public async Task<UserRelationshipResponse> FollowAsync(int userId)
        {
            var currentUserId = _currentUserService.GetUserId();

            if (currentUserId == userId)
                throw new ClientException("You cannot follow yourself.");

            await EnsureUserExistsAsync(userId);

            if (await IsBlockedEitherWayAsync(currentUserId, userId))
                throw new ClientException("You cannot follow a user you have blocked, or who has blocked you.");

            if (await _context.UserFollows.AnyAsync(x => x.FollowerId == currentUserId && x.FollowingId == userId))
                return await BuildRelationshipAsync(userId);

            _context.UserFollows.Add(new UserFollow
            {
                FollowerId = currentUserId,
                FollowingId = userId,
                CreatedAt = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();
            await SyncFriendshipAsync(currentUserId, userId);

            await _activityService.InsertAsync(currentUserId, new ActivityInsertRequest
            {
                Type = ActivityType.FollowedUser,
                TargetUserId = userId
            });

            return await BuildRelationshipAsync(userId);
        }

        public async Task<UserRelationshipResponse> UnfollowAsync(int userId)
        {
            var currentUserId = _currentUserService.GetUserId();

            var follow = await _context.UserFollows
                .FirstOrDefaultAsync(x => x.FollowerId == currentUserId && x.FollowingId == userId);

            if (follow is null)
                return await BuildRelationshipAsync(userId);

            _context.UserFollows.Remove(follow);

            await RemoveFollowActivitiesAsync(currentUserId, userId);

            await _context.SaveChangesAsync();
            await SyncFriendshipAsync(currentUserId, userId);

            return await BuildRelationshipAsync(userId);
        }

        public async Task<UserRelationshipResponse> BlockAsync(int userId)
        {
            var currentUserId = _currentUserService.GetUserId();

            if (currentUserId == userId)
                throw new ClientException("You cannot block yourself.");

            await EnsureUserExistsAsync(userId);

            if (!await _context.UserBlocks.AnyAsync(x => x.BlockerId == currentUserId && x.BlockedId == userId))
            {
                _context.UserBlocks.Add(new UserBlock
                {
                    BlockerId = currentUserId,
                    BlockedId = userId,
                    CreatedAt = DateTime.UtcNow
                });
            }

            var follows = await _context.UserFollows
                .Where(x => (x.FollowerId == currentUserId && x.FollowingId == userId)
                         || (x.FollowerId == userId && x.FollowingId == currentUserId))
                .ToListAsync();

            _context.UserFollows.RemoveRange(follows);

            await RemoveFollowActivitiesAsync(currentUserId, userId);
            await RemoveFollowActivitiesAsync(userId, currentUserId);

            await _context.SaveChangesAsync();

            return await BuildRelationshipAsync(userId);
        }

        public async Task<UserRelationshipResponse> UnblockAsync(int userId)
        {
            var currentUserId = _currentUserService.GetUserId();

            var block = await _context.UserBlocks
                .FirstOrDefaultAsync(x => x.BlockerId == currentUserId && x.BlockedId == userId);

            if (block is null)
                return await BuildRelationshipAsync(userId);

            _context.UserBlocks.Remove(block);

            await _context.SaveChangesAsync();

            return await BuildRelationshipAsync(userId);
        }

        public async Task ReportAsync(UserReportInsertRequest request)
        {
            await _reportValidator.ValidateAndThrowAsync(request);

            var currentUserId = _currentUserService.GetUserId();

            if (currentUserId == request.ReportedUserId)
                throw new ClientException("You cannot report yourself.");

            await EnsureUserExistsAsync(request.ReportedUserId);

            if (await _context.UserReports.AnyAsync(x => x.ReporterId == currentUserId
                    && x.ReportedUserId == request.ReportedUserId
                    && x.Status == ReportStatus.Open))
                throw new ClientException("You have already reported this user. An admin is looking into it.");

            _context.UserReports.Add(new UserReport
            {
                ReporterId = currentUserId,
                ReportedUserId = request.ReportedUserId,
                Header = request.Header.Trim(),
                Description = Normalize(request.Description),
                Status = ReportStatus.Open,
                CreatedAt = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();
        }

        private static string? Normalize(string? value)
            => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

        private async Task<UserRelationshipResponse> BuildRelationshipAsync(int userId)
        {
            var currentUserId = _currentUserService.GetUserId();

            var follows = await _context.UserFollows
                .Where(x => (x.FollowerId == currentUserId && x.FollowingId == userId)
                         || (x.FollowerId == userId && x.FollowingId == currentUserId))
                .Select(x => x.FollowerId)
                .ToListAsync();

            var blocks = await _context.UserBlocks
                .Where(x => (x.BlockerId == currentUserId && x.BlockedId == userId)
                         || (x.BlockerId == userId && x.BlockedId == currentUserId))
                .Select(x => x.BlockerId)
                .ToListAsync();

            return new UserRelationshipResponse
            {
                UserId = userId,
                IsSelf = currentUserId == userId,
                IsFollowing = follows.Contains(currentUserId),
                IsFollowedBy = follows.Contains(userId),
                IsBlocked = blocks.Contains(currentUserId),
                IsBlockedBy = blocks.Contains(userId)
            };
        }

        private async Task SyncFriendshipAsync(int firstUserId, int secondUserId)
        {
            var edges = await _context.UserFollows
                .Where(x => (x.FollowerId == firstUserId && x.FollowingId == secondUserId)
                         || (x.FollowerId == secondUserId && x.FollowingId == firstUserId))
                .ToListAsync();

            var isFriend = edges.Count == 2;

            foreach (var edge in edges)
                edge.IsFriend = isFriend;

            await _context.SaveChangesAsync();
        }

        private async Task RemoveFollowActivitiesAsync(int userId, int targetUserId)
        {
            var activities = await _context.Activities
                .Where(x => x.Type == ActivityType.FollowedUser
                    && x.UserId == userId
                    && x.TargetUserId == targetUserId)
                .ToListAsync();

            _context.Activities.RemoveRange(activities);
        }

        private Task<bool> IsBlockedEitherWayAsync(int firstUserId, int secondUserId)
            => _context.UserBlocks.AnyAsync(x =>
                (x.BlockerId == firstUserId && x.BlockedId == secondUserId)
                || (x.BlockerId == secondUserId && x.BlockedId == firstUserId));

        private async Task EnsureUserExistsAsync(int userId)
        {
            if (!await _context.Users.AnyAsync(x => x.Id == userId))
                throw new ClientException($"User with Id {userId} not found.");
        }

        private async Task<PageResult<UserResponse>> GetPagedAsync(IQueryable<User> query, BaseSearchObject? search)
        {
            int? totalCount = null;

            if (search?.IncludeTotalCount ?? false)
                totalCount = await query.CountAsync();

            if (search?.Page is int page && search.PageSize is int size)
                query = query.Skip((page - 1) * size);

            if (search?.PageSize is int pageSize)
                query = query.Take(pageSize);

            var users = await query.ToListAsync();

            return new PageResult<UserResponse>
            {
                Items = users.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        private UserResponse MapToResponse(User entity)
        {
            var response = _mapper.Map<UserResponse>(entity);

            _imageUrlResolver.Resolve(response);

            return response;
        }
    }
}
