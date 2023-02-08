using Application.Common.Abstracts.Persistence.Database.Repositories;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Database.Repositories;
using Domain.Entities;

namespace Application.Persistence.Database.Repositories;

public class HistoricalPositionRepository : BaseRepository<HistoricalPosition>, IHistoricalPositionRepository
{
    public HistoricalPositionRepository(IApplicationDbContext context) : base(context)
    {
    }
}