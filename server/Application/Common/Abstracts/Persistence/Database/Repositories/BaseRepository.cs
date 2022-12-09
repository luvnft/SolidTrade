using System.Linq.Expressions;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Database.Repositories;
using Application.Errors.Common;
using Application.Models.Types;
using Domain.Entities.Base;
using Microsoft.EntityFrameworkCore;

namespace Application.Common.Abstracts.Persistence.Database.Repositories;

public abstract class BaseRepository<TEntity> : IRepository<TEntity> where TEntity : BaseEntity
{
    private DbSet<TEntity> Set { get; }

    protected BaseRepository(IApplicationDbContext context)
    {
        Set = context.DbSet<TEntity>();
    }

    public Task<Result<bool>> AnyAsync(int entityId)
        => AnyAsync(e => e.Id == entityId);

    public async Task<Result<bool>> AnyAsync(Expression<Func<TEntity, bool>> predicate)
    {
        try
        {
            return await Set.AnyAsync(predicate);
        }
        catch (Exception e)
        {
            return OnUnexpectedError(DefaultErrorMessage(), e);
        }
    }

    public async Task<Result<TEntity>> FindByIdAsync(int entityId)
    {
        try
        {
            var entity = await Set.FindAsync(entityId);

            if (entity == null)
            {
                return new NotFound
                {
                    Title = "Not found",
                    Message = DefaultErrorMessageWithId(entityId),
                    UserFriendlyMessage = ErrorMessages.NotFoundErrorMessage,
                };
            }

            return entity;
        }
        catch (Exception e)
        {
            return OnUnexpectedError(DefaultErrorMessageWithId(entityId), e);
        }
    }

    public async Task<Result<TEntity>> FirstAsync(Expression<Func<TEntity, bool>> predicate, params Expression<Func<TEntity, object>>[] navigationPropertyPaths)
    {
        try
        {
            var queryable = Set.AsQueryable();

            foreach (var navigationPropertyPath in navigationPropertyPaths)
                queryable = queryable.Include(navigationPropertyPath);

            var query = queryable.Where(predicate);
            var entity = await query.FirstOrDefaultAsync();
            
            if (entity == null)
            {
                return new NotFound
                {
                    Title = "Not found",
                    Message = DefaultErrorMessage(),
                    UserFriendlyMessage = ErrorMessages.NotFoundErrorMessage,
                };
            }

            return entity;
        }
        catch (Exception e)
        {
            return OnUnexpectedError(DefaultErrorMessage(), e);
        }
    }
    
    
    public async Task<Result<List<TEntity>>> FindAsync(Expression<Func<TEntity, bool>> predicate, params Expression<Func<TEntity, object>>[] navigationPropertyPaths)
    {
        try
        {
            var queryable = Set.AsQueryable();

            foreach (var navigationPropertyPath in navigationPropertyPaths)
                queryable = queryable.Include(navigationPropertyPath);

            var query = queryable.Where(predicate);
            return await query.ToListAsync();
        }
        catch (Exception e)
        {
            return OnUnexpectedError(DefaultErrorMessage(), e);
        }
    }

    public void Add(TEntity entity)
        => Set.Add(entity);

    public void AddRange(IEnumerable<TEntity> entities)
        => Set.AddRange(entities);

    public void Update(TEntity entity)
        => Set.Update(entity);

    public void UpdateRange(IEnumerable<TEntity> entities)
        => Set.UpdateRange(entities);

    public void Remove(TEntity entity)
        => Set.Remove(entity);

    public void RemoveRange(IEnumerable<TEntity> entities)
        => Set.RemoveRange(entities);

    protected string DefaultErrorMessageWithId(int id)
        => $"Failed to fetch entity of type '{typeof(TEntity)}' with id '{id}'";

    protected string DefaultErrorMessage()
        => $"Failed to fetch entities of type '{typeof(TEntity)}'";

    protected UnexpectedDatabaseError OnUnexpectedError(string message, Exception e)
        => new()
        {
            Title = ErrorMessages.UnexpectedErrorTitle,
            Exception = e,
            Message = message,
            UserFriendlyMessage = ErrorMessages.UnexpectedErrorFriendlyMessage,
        };
}