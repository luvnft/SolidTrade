using Application.Common;
using Application.Common.Interfaces.Persistence;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services.Jobs;
using Application.Errors.Types;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Serilog;

namespace Application.Services.Jobs;

public class RemoveOngoingExpiredTradeJob : IBackgroundJob<RemoveOngoingExpiredTradeJob>
{
    public string JobTitle => "Remove expired standing orders";
    
    private readonly ILogger _logger = Log.ForContext<RemoveOngoingExpiredTradeJob>();
    private readonly IServiceScopeFactory _scopeFactory;
        
    public RemoveOngoingExpiredTradeJob(IServiceScopeFactory scopeFactory)
    {
        _scopeFactory = scopeFactory;
    }
        
    public Task StartAsync()
    {
        try
        {
            _logger.Information("Removing expired standing order from database.");
            return RemoveExpiredTradesAsync();
        }
        catch (Exception e)
        {
            _logger.Error(ApplicationConstants.LogMessageTemplate, new UnexpectedError
            {
                Title = "Could not remove expired standing orders.",
                Message = "Something went wrong trying to remove all standing orders. See exception for more.",
                Exception = e,
            });
            return Task.CompletedTask;
        }
    }

    private async Task RemoveExpiredTradesAsync()
    {
        await using var database = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IApplicationDbContext>();

        var expiredPositions = database.StandingOrders.AsQueryable().Where(p => DateTimeOffset.Now > p.GoodUntil);
        var expiredPositionsCount = await expiredPositions.CountAsync();
            
        database.StandingOrders.RemoveRange(expiredPositions);
        await database.SaveChangesAsync();
        _logger.Information("Removed {@expiredPositionsCount} expired standing orders from database.", expiredPositionsCount);
    }
}
