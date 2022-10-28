using Application.Common;
using Application.Common.Interfaces.Persistence;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.Jobs;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Errors;
using Application.Errors.Common;
using Application.Models.Dtos.Shared.Common;
using Application.Models.Dtos.TradeRepublic;
using Application.Models.Dtos.Warrant.Response;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using OneOf;
using Serilog;

namespace Application.Services.Jobs;

public class RemoveExpiredWarrantProductsJob : IBackgroundJob<RemoveExpiredWarrantProductsJob>
{
    public string JobTitle => "Remove Expired warrants";
    
    private readonly ILogger _logger = Log.ForContext<RemoveExpiredWarrantProductsJob>();
    private readonly ITradeRepublicApiService _tradeRepublicApiService;
    private readonly IServiceScopeFactory _scopeFactory;

    public RemoveExpiredWarrantProductsJob(ITradeRepublicApiService tradeRepublicApiService, IServiceScopeFactory scopeFactory)
    {
        _tradeRepublicApiService = tradeRepublicApiService;
        _scopeFactory = scopeFactory;
    }
        
    public Task StartAsync()
    {
        try
        {
            _logger.Information("Removing expired warrant products from database.");
            return RemoveKnockedOutProducts();
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

    private async Task RemoveKnockedOutProducts()
    {
        await using var database = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IApplicationDbContext>();
        using var warrantService = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IWarrantService>();
            
        var warrantPositions = await database.WarrantPositions
            .Include(w => w.Portfolio).ThenInclude(p => p.User).AsQueryable().ToListAsync();
            
        var tasks = new List<Task<OneOf<TradeRepublicProductInfoDto, ErrorResponse>>>();
            
        foreach (var warrantPosition in warrantPositions)
        {
            tasks.Add(_tradeRepublicApiService.MakeTrRequest<TradeRepublicProductInfoDto>(
                Shared.GetTradeRepublicProductInfoRequestString(warrantPosition.Isin)));
        }
            
        var results = await Task.WhenAll(tasks);

        var trProductInfos = results.Where(oneOfResult => oneOfResult.IsT0).Select(oneOfResult => oneOfResult.AsT0);
        var errors = results.Where(oneOfResult => oneOfResult.IsT1).Select(oneOfResult => oneOfResult.AsT1);

        if (errors.Any())
        {
            foreach (var error in errors)
                _logger.Warning(ApplicationConstants.LogMessageTemplate, error);
            return;
        }

        var warrantsTasks = new List<Task<OneOf<WarrantPositionResponseDto, ErrorResponse>>>();
        foreach (var trProductInfo in trProductInfos)
        {
            var warrantPosition = warrantPositions.Find(k => k.Isin == trProductInfo.Isin);
                
            // We could also check if it is still active or not. The result would be the same.
            if (DateTime.Now > trProductInfo.DerivativeInfo.Properties.Expiry)
            {
                var warrantTask = warrantService.SellWarrantInternal(database,
                    new BuyOrSellRequestDto
                        {Isin = $"{warrantPosition!.Isin}.{trProductInfo.ExchangeIds.First()}", NumberOfShares = warrantPosition.NumberOfShares},
                    warrantPosition.Portfolio.User);
                    
                warrantsTasks.Add(warrantTask);
            }
        }
            
        var warrantResults = await Task.WhenAll(warrantsTasks);

        var warrantPositionDtos = warrantResults.Where(oneOfResult => oneOfResult.IsT0).Select(oneOfResult => oneOfResult.AsT0);
        var warrantErrors = warrantResults.Where(oneOfResult => oneOfResult.IsT1).Select(oneOfResult => oneOfResult.AsT1);

        foreach (var errorResponse in warrantErrors)
            _logger.Warning(ApplicationConstants.LogMessageTemplate, errorResponse.Error);
            
        _logger.Information("Removed {@RemovedWarrantPositionCount} expired warrants from database.", warrantPositionDtos.Count());
    }
}