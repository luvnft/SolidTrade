using Application.Common.Interfaces.Persistence.Database.Repositories;
using Success = OneOf.Types.Success;

namespace Application.Common.Interfaces.Persistence.Database;

public interface IUnitOfWork
{
    IStockRepository Stocks { get; }
    IUserRepository Users { get; }
    IPortfolioRepository Portfolios { get; }
    IHistoricalPositionRepository HistoricalPositions { get; }
    Task<Result<Success>> Commit();
}