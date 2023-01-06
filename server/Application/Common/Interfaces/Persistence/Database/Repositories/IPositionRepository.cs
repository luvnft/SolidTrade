using Domain.Entities;

namespace Application.Common.Interfaces.Persistence.Database.Repositories;

public interface IPositionRepository : IRepository<Position>
{
    Task<Result<(bool PositionAlreadyExists, Position ExisingPosition)>> ShouldAddOrUpdatePositionAsync(string positionIsin, int portfolioId);
    Task<Result<Position>> FindPositionAsync(string isin, int portfolioId);
}