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
        public DbSet<StockPosition> StockPositions { get; }
        public DbSet<WarrantPosition> WarrantPositions { get; }
        public DbSet<KnockoutPosition> KnockoutPositions { get; }
        public DbSet<OngoingWarrantPosition> OngoingWarrantPositions { get; }
        public DbSet<OngoingKnockoutPosition> OngoingKnockoutPositions { get; }
        public DbSet<ProductImageRelation> ProductImageRelations { get; }
    
        public DatabaseFacade Database { get; }

        DbSet<TEntity> DbSet<TEntity>() where TEntity : BaseEntity;

        int SaveChanges();
        Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    }
}