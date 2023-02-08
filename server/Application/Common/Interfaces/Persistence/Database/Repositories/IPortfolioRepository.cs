using Domain.Entities;

namespace Application.Common.Interfaces.Persistence.Database.Repositories;

public interface IPortfolioRepository : IRepository<Portfolio>
{
    public Task<Result<Portfolio>> GetPortfolioByIdAndIncludeAll(int id);
    public Task<Result<Portfolio>> GetPortfolioByUserIdAndIncludeAll(int userId);
}