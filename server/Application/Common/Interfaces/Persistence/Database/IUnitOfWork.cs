using Application.Common.Interfaces.Persistence.Database.Repositories;
using Application.Models.Types;
using Success = OneOf.Types.Success;

namespace Application.Common.Interfaces.Persistence.Database;

public interface IUnitOfWork
{
    IStockRepository Stocks { get; }
    IUserRepository Users { get; }
    Task<Result<Success>> Commit();
}