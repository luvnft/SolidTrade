﻿using System.Linq.Expressions;
using Application.Common.Abstracts.Persistence.Database.Repositories;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Database.Repositories;
using Domain.Entities;

namespace Application.Persistence.Database.Repositories;

public class PortfolioRepository : BaseRepository<Portfolio>, IPortfolioRepository
{
    public PortfolioRepository(IApplicationDbContext context) : base(context)
    {
    }

    public Task<Result<Portfolio>> GetPortfolioByIdAndIncludeAll(int id)
    {
        return FirstAsync(
            p => p.Id == id, AllPortfolioNavigationProperties);
    }

    public Task<Result<Portfolio>> GetPortfolioByUserIdAndIncludeAll(int userId)
    {
        return FirstAsync(
            p => p.UserId == userId, AllPortfolioNavigationProperties);
    }

    private static Expression<Func<Portfolio, object>>[] AllPortfolioNavigationProperties => new Expression<Func<Portfolio, object>>[]
    {
        p => p.User,
        p => p.Positions,
        p => p.StandingOrders,
    };
}