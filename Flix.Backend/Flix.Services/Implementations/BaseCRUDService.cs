using Flix.Model.SearchObjects;
using Flix.Services.Interfaces;
using FluentValidation;
using Microsoft.EntityFrameworkCore.Update;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Text;

namespace Flix.Services.Implementations
{
    public abstract class BaseCRUDService<TEntity, TResponse, TSearch, TInsertRequest, TUpdateRequest>
        : BaseReadService<TEntity, TResponse, TSearch>, IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
        where TEntity : class
        where TSearch : BaseSearchObject
    {
        private readonly IValidator<TInsertRequest> _insertValidator;
        private readonly IValidator<TUpdateRequest> _updateValidator;

        protected BaseCRUDService(
            MapsterMapper.IMapper mapper, 
            IValidator<TInsertRequest> insertValidator, 
            IValidator<TUpdateRequest> updateValidator)
            : base(mapper)
        {
            _insertValidator = insertValidator;
            _updateValidator = updateValidator;
        }

        protected abstract IList<TEntity> GetWriteableDataSource();

        protected virtual int GenerateNewId()
        {
            var dataSource = GetWriteableDataSource();
            if (dataSource.Count == 0)
                return 1;

            return dataSource.Max(e => (int)e.GetType().GetProperty("Id").GetValue(e)) + 1;
        }

        protected virtual TEntity MapInsertRequestToEntity(TInsertRequest request)
        {
            return _mapper.Map<TEntity>(request ?? throw new ArgumentNullException(nameof(request)));
        }

        protected virtual void MapUpdateRequestToEntity(TUpdateRequest request, TEntity entity)
        {
            _mapper.Map(request, entity);
        }   

        public async Task DeleteAsync(int id)
        {
            var dataSource = GetWriteableDataSource();
            var entity = dataSource.FirstOrDefault(e => (int)e.GetType().GetProperty("Id").GetValue(e) == id);

            if(entity is null) 
                throw new KeyNotFoundException($"{typeof(TEntity).Name} with Id {id} not found.");

            dataSource.Remove(entity);
            await Task.CompletedTask;
        }

        public async Task<TResponse> InsertAsync(TInsertRequest request)
        {
            var validationResult = await _insertValidator.ValidateAsync(request);
            if(validationResult.IsValid == false)
            {
                var errors = validationResult.Errors.Select(e => _mapper.Map<ValidationFailure>(e)).ToList();
                foreach(var error in errors) 
                    throw new FluentValidation.ValidationException(error.ToString());
            }

            var entity = MapInsertRequestToEntity(request);

            var entityType = entity.GetType();
            var idProperty = entityType.GetProperty("Id");
            idProperty?.SetValue(entity, GenerateNewId());

            var createdAtProperty = entityType.GetProperty("CreatedAt");
            if(createdAtProperty?.CanWrite == true)
                createdAtProperty.SetValue(entity, DateTime.UtcNow);

            var dataSource = GetWriteableDataSource();
            dataSource.Add(entity);

            return await Task.FromResult(_mapper.Map<TResponse>(entity));
        }

        public async Task<TResponse> UpdateAsync(int id, TUpdateRequest request)
        {
            var validationResult = await _updateValidator.ValidateAsync(request);
            if (validationResult.IsValid == false)
            {
                var errors = validationResult.Errors.Select(e => _mapper.Map<ValidationFailure>(e)).ToList();
                foreach (var error in errors)
                    throw new FluentValidation.ValidationException(error.ToString());
            }
            
            var dataSource = GetWriteableDataSource();
            var entity = dataSource.FirstOrDefault(e => (int)e.GetType().GetProperty("Id").GetValue(e) == id);

            if(entity is null)
                throw new KeyNotFoundException($"{typeof(TEntity).Name} with Id {id} not found.");

            MapUpdateRequestToEntity(request, entity);

            var updatedAtProperty = entity.GetType().GetProperty("UpdatedAt");
            if(updatedAtProperty?.CanWrite == true)
                updatedAtProperty.SetValue(entity, DateTime.UtcNow);

            return await Task.FromResult(_mapper.Map<TResponse>(entity));
        }
    }
}
