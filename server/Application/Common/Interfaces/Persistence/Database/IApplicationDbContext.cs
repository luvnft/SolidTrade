using Domain.Entities;
using Domain.Entities.Base;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;

namespace Application.Common.Interfaces.Persistence.Database
{
    public interface IApplicationDbContext : IDisposable, IAsyncDisposable
    {
        public DbSet<HistoricalPosition> HistoricalPositions { get; }
        public DbSet<User> Users { get; }
        public DbSet<Portfolio> Portfolios { get; }
        public DbSet<Position> Positions { get; }
        public DbSet<StandingOrder> StandingOrders { get; }
        public DbSet<ProductImageRelation> ProductImageRelations { get; }
    
        public DatabaseFacade Database { get; }

        DbSet<TEntity> DbSet<TEntity>() where TEntity : BaseEntity;

        int SaveChanges();
        Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    }
}