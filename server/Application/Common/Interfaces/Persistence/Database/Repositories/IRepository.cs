using System.Linq.Expressions;
using Domain.Entities.Base;
using Microsoft.EntityFrameworkCore.ChangeTracking;

namespace Application.Common.Interfaces.Persistence.Database.Repositories;

public interface IRepository<TEntity> where TEntity : BaseEntity
{
    Task<Result<bool>> AnyAsync(int entityId);
    Task<Result<bool>> AnyAsync(Expression<Func<TEntity, bool>> predicate);
    Task<Result<TEntity>> FindByIdAsync(int entityId);
    Task<Result<TEntity>> FirstAsync(Expression<Func<TEntity, bool>> predicate, params Expression<Func<TEntity, object>>[] navigationPropertyPaths);
    Task<Result<List<TEntity>>> FindAsync(Expression<Func<TEntity, bool>> predicate, params Expression<Func<TEntity, object>>[] navigationPropertyPaths);
    
    EntityEntry<TEntity> Add(TEntity entity);
    void AddRange(IEnumerable<TEntity> entities);
    
    EntityEntry<TEntity> Update(TEntity entity);
    void UpdateRange(IEnumerable<TEntity> entities);
    
    void Remove(TEntity entity);
    void RemoveRange(IEnumerable<TEntity> entities);
}