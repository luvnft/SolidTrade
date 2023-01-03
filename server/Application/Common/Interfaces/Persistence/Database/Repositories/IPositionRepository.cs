using Domain.Entities;

namespace Application.Common.Interfaces.Persistence.Database.Repositories;

public interface IPositionRepository : IRepository<Position>
{
    Task<Result<(bool PositionAlreadyExists, Position ExisingPosition)>> ShouldAddOrUpdatePositionAsync(Position position, int portfolioId);
    Task<Result<Position>> FindPositionAsync(string isin, int portfolioId);
}