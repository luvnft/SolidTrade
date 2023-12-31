﻿using Application.Common;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Database.Repositories;

namespace Application.Persistence.Database;

public class UnitOfWork : IUnitOfWork
{
    private readonly IApplicationDbContext _context;
    public IUserRepository Users { get; }
    public IPortfolioRepository Portfolios { get; }
    public IPositionRepository Positions { get; }
    public IHistoricalPositionRepository HistoricalPositions { get; }
    public IStandingOrderRepository StandingOrders { get; }

    public UnitOfWork(IApplicationDbContext context, IUserRepository users, IPortfolioRepository portfolios, IHistoricalPositionRepository historicalPositions, IPositionRepository positions, IStandingOrderRepository standingOrders)
    {
        _context = context;
        Users = users;
        Portfolios = portfolios;
        HistoricalPositions = historicalPositions;
        Positions = positions;
        StandingOrders = standingOrders;
    }

    public async Task<Result<OneOf.Types.Success>> Commit()
    {
        try
        {
            await _context.SaveChangesAsync();
            return new OneOf.Types.Success();
        }
        catch (Exception e)
        {
            return new UnexpectedDatabaseError
            {
                Title = ErrorMessages.UnexpectedErrorTitle,
                Exception = e,
                Message = "Failed to commit changes to database.",
                UserFriendlyMessage = ErrorMessages.UnexpectedErrorFriendlyMessage,
            };
        }
    }

    // TODO: Verify that this is the correct way to dispose of the context.
    public void Dispose() => _context?.Dispose();
}