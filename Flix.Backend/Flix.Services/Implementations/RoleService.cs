using Flix.Model.Responses;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using MapsterMapper;

namespace Flix.Services.Implementations
{
    public class RoleService : BaseReadService<Role, RoleResponse, RoleSearchObject>, IRoleService
    {
        public RoleService(FlixDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Role> GetDataSource() => _context.Set<Role>().OrderBy(r => r.Id);

        protected override IEnumerable<Role> ApplyFilters(IQueryable<Role> query, RoleSearchObject? search)
        {
            if (search != null)
            {
                if (!string.IsNullOrWhiteSpace(search.Name?.Trim()))
                    query = query.Where(x => x.Name.ToLower().Contains(search.Name.Trim().ToLower()));

                if (search.IsActive is bool isActive)
                    query = query.Where(x => x.IsActive == isActive);
            }

            return query;
        }
    }
}
