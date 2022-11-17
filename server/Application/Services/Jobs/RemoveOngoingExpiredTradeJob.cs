using Application.Common;
using Application.Common.Interfaces.Persistence;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services.Jobs;
using Application.Errors.Common;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Serilog;

namespace Application.Services.Jobs;

public class RemoveOngoingExpiredTradeJob : IBackgroundJob<RemoveOngoingExpiredTradeJob>
{
    public string JobTitle => "Remove Ongoing expired orders";
    
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
            _logger.Information("Removing expired ongoing trades from database.");
            return RemoveExpiredTradesAsync();
        }
        catch (Exception e)
        {
            _logger.Error(ApplicationConstants.LogMessageTemplate, new UnexpectedError
            {
                Title = "Could not remove expired trades",
                Message = "Something went wrong trying to remove expired trades. See exception for more.",
                Exception = e,
            });
            return Task.CompletedTask;
        }
    }

    private async Task RemoveExpiredTradesAsync()
    {
        await using IApplicationDbContext database = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IApplicationDbContext>();

        var expiredKnockouts = database.OngoingKnockoutPositions.AsQueryable().Where(p => DateTimeOffset.Now > p.GoodUntil);
        var expiredWarrants = database.OngoingWarrantPositions.AsQueryable().Where(p => DateTimeOffset.Now > p.GoodUntil);

        var expiredKnockoutsCount = await expiredKnockouts.CountAsync();
        var expiredWarrantsCount = await expiredWarrants.CountAsync();
            
        database.OngoingKnockoutPositions.RemoveRange(expiredKnockouts);
        database.OngoingWarrantPositions.RemoveRange(expiredWarrants);

        await database.SaveChangesAsync();
        _logger.Information("Removed {@expiredKnockoutsCount} expired ongoing knockouts and {@expiredWarrantsCount} expired ongoing warrants from database.", expiredKnockoutsCount, expiredWarrantsCount);
    }
}