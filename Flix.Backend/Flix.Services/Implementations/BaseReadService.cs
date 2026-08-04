using Flix.Model.Exceptions;
using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;


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

        protected virtual async Task<IQueryable<TEntity>> IncludeRelatedEntities(TSearch? search, IQueryable<TEntity> query)
        {
            // Override this method in derived classes to include related entities based on the search object.
            return query;
        }

        public async Task<PageResult<TResponse>> GetAsync(TSearch? search = null)
        {
            var query = await IncludeRelatedEntities(search, GetDataSource());
            query = ApplyFilters(query, search).AsQueryable();

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

        public virtual async Task<TResponse> GetByIdAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);

            if (entity is null)
                throw new ClientException($"{typeof(TEntity).Name} with Id {id} not found.");

            return _mapper.Map<TResponse>(entity);
        }
    }
}