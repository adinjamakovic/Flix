using Flix.Model.Exceptions;
using Flix.Model.SearchObjects;
using Flix.Services.Database;
using Flix.Services.Interfaces;
using FluentValidation;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace Flix.Services.Implementations
{
    public abstract class BaseCRUDService<TEntity, TResponse, TSearch, TInsertRequest, TUpdateRequest>
        : BaseReadService<TEntity, TResponse, TSearch>, IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
        where TEntity : class
        where TSearch : BaseSearchObject
    {
        protected readonly IValidator<TInsertRequest> _insertValidator;
        protected readonly IValidator<TUpdateRequest> _updateValidator;

        protected BaseCRUDService(
            FlixDbContext context,
            MapsterMapper.IMapper mapper,
            IValidator<TInsertRequest> insertValidator,
            IValidator<TUpdateRequest> updateValidator)
            : base(context, mapper)
        {
            _insertValidator = insertValidator;
            _updateValidator = updateValidator;
        }

        protected virtual TEntity MapInsertRequestToEntity(TInsertRequest request)
        {
            return _mapper.Map<TEntity>(request ?? throw new ArgumentNullException(nameof(request)));
        }

        protected virtual void MapUpdateRequestToEntity(TUpdateRequest request, TEntity entity)
        {
            _mapper.Map(request, entity);
        }

        protected virtual Task BeforeInsertAsync(TEntity entity, TInsertRequest request) => Task.CompletedTask;

        protected virtual Task BeforeUpdateAsync(TEntity entity, TUpdateRequest request) => Task.CompletedTask;

        protected virtual Task BeforeDeleteAsync(TEntity entity) => Task.CompletedTask;

        protected virtual Task AfterDeleteAsync(TEntity entity) => Task.CompletedTask;

        protected virtual string DescribeEntity(TEntity entity) => typeof(TEntity).Name;

        protected virtual Task<string?> DescribeUsageAsync(TEntity entity) => Task.FromResult<string?>(null);

        public virtual async Task<TResponse> InsertAsync(TInsertRequest request)
        {
            await _insertValidator.ValidateAndThrowAsync(request);

            var entity = MapInsertRequestToEntity(request);
            await BeforeInsertAsync(entity, request);

            await _context.Set<TEntity>().AddAsync(entity);
            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }

        public virtual async Task<TResponse> UpdateAsync(int id, TUpdateRequest request)
        {
            await _updateValidator.ValidateAndThrowAsync(request);

            var entity = await _context.Set<TEntity>().FindAsync(id);

            if (entity is null)
                throw new ClientException($"{typeof(TEntity).Name} with Id {id} not found.");

            MapUpdateRequestToEntity(request, entity);
            await BeforeUpdateAsync(entity, request);

            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }

        public virtual async Task DeleteAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);

            if (entity is null)
                throw new ClientException($"{typeof(TEntity).Name} with Id {id} not found.");

            await BeforeDeleteAsync(entity);

            _context.Set<TEntity>().Remove(entity);

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException ex) when (IsForeignKeyViolation(ex))
            {
                var usage = await DescribeUsageAsync(entity);
                var subject = DescribeEntity(entity);

                throw new ClientException(usage is null
                    ? $"{subject} cannot be deleted because other records still reference it."
                    : $"{subject} cannot be deleted because it is used by {usage}.");
            }

            await AfterDeleteAsync(entity);
        }

        private static bool IsForeignKeyViolation(DbUpdateException exception)
            => exception.InnerException is SqlException { Number: 547 };
    }
}