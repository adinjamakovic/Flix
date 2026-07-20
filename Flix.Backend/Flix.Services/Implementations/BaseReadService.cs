using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using Microsoft.EntityFrameworkCore;


namespace Flix.Services.Implementations
{
    public abstract class BaseReadService<TEntity, TResponse, TSearch> : IBaseReadService<TResponse, TSearch>
        where TEntity : class
        where TSearch : BaseSearchObject
    {
        protected readonly FlixDbContext _context;
        protected readonly MapsterMapper.IMapper _mapper;

        protected BaseReadService(FlixDbContext context, MapsterMapper.IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        protected virtual IQueryable<TEntity> GetDataSource() => _context.Set<TEntity>();

        protected abstract IEnumerable<TEntity> ApplyFilters(IQueryable<TEntity> query, TSearch? search);

        public async Task<PageResult<TResponse>> GetAsync(TSearch? search = null)
        {
            IEnumerable<TEntity> query = ApplyFilters(GetDataSource(), search);

            int? totalCount = null;

            if (search?.IncludeTotalCount ?? false)
                totalCount = query.Count();

            if (search?.Page is int page && search.PageSize is int size)
                query = query.Skip((page - 1) * size);

            if (search?.PageSize is int pageSize)
                query = query.Take(pageSize);

            var entities = query.Select(x => _mapper.Map<TResponse>(x)).ToList();

            return new PageResult<TResponse>
            {
                Items = entities,
                TotalCount = totalCount
            };
        }

        public async Task<TResponse> GetByIdAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);

            if (entity is null)
                throw new KeyNotFoundException($"{typeof(TEntity).Name} with Id {id} not found.");

            return _mapper.Map<TResponse>(entity);
        }
    }
}