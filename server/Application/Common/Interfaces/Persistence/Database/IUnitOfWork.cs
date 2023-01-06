using Application.Common.Interfaces.Persistence.Database.Repositories;
using Success = OneOf.Types.Success;

namespace Application.Common.Interfaces.Persistence.Database;

public interface IUnitOfWork : IDisposable
{
    IUserRepository Users { get; }
    IPortfolioRepository Portfolios { get; }
    IPositionRepository Positions { get; }
    IHistoricalPositionRepository HistoricalPositions { get; }
    IStandingOrderRepository StandingOrders { get; }
    Task<Result<Success>> Commit();
}