using Application.Common.Abstracts.Persistence.Database.Repositories;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Database.Repositories;
using Domain.Entities;

namespace Application.Persistence.Database.Repositories;

public class StandingOrderRepository : BaseRepository<StandingOrder>, IStandingOrderRepository
{
    public StandingOrderRepository(IApplicationDbContext context) : base(context)
    {
    }
}