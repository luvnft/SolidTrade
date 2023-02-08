using Application.Common.Abstracts.Persistence.Database.Repositories;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Database.Repositories;
using Domain.Entities;

namespace Application.Persistence.Database.Repositories;

public class PositionRepository : BaseRepository<Position>, IPositionRepository
{
    public PositionRepository(IApplicationDbContext context) : base(context)
    {
    }

    public async Task<Result<(bool PositionAlreadyExists, Position ExisingPosition)>> ShouldAddOrUpdatePositionAsync(string positionIsin, int portfolioId)
    {
        var existingPositionQuery = await FindPositionAsync(positionIsin, portfolioId);
        if (existingPositionQuery.TryTakeResult(out var existingPosition, out var error))
            return (true, existingPosition);

        return error is EntityNotFound ? (false, null) : error;
    }

    public async Task<Result<Position>> FindPositionAsync(string isin, int portfolioId) =>
        await FirstAsync(p => p.Isin == isin && p.Portfolio.Id == portfolioId);
}