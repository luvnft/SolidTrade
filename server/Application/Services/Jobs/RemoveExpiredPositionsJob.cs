using System.Collections.Concurrent;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.Jobs;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Extensions;
using Application.Models.Dtos.Shared.Common;
using Application.Models.Dtos.TradeRepublic;
using Domain.Enums;
using Microsoft.Extensions.DependencyInjection;
using Serilog;
using Success = OneOf.Types.Success;

namespace Application.Services.Jobs;

public class RemoveExpiredPositionsJob : IBackgroundJob<RemoveExpiredPositionsJob>
{
    public string JobTitle => "Remove Expired positions";
    
    private readonly ILogger _logger = Log.ForContext<RemoveExpiredPositionsJob>();
    private readonly ITradeRepublicApiService _tradeRepublicApiService;
    private readonly IServiceScopeFactory _scopeFactory;

    public RemoveExpiredPositionsJob(ITradeRepublicApiService tradeRepublicApiService, IServiceScopeFactory scopeFactory)
    {
        _tradeRepublicApiService = tradeRepublicApiService;
        _scopeFactory = scopeFactory;
    }
    
    // TODO: Verify behaviour is correct for knockout. Since when expired should not yield any profit. See here: https://github.com/SolomonRosemite/SolidTrade/blob/8c0efe9b90ccffb7172da9a6bf89fc61f78a2b33/server/Services/Jobs/RemoveKnockedOutProductsJobsService.cs#L82
    public async Task StartAsync()
    {
        await StartRemovingExpiredPositionsAsync(PositionType.Knockout);
        await StartRemovingExpiredPositionsAsync(PositionType.Warrant);
    }
    
    private async Task StartRemovingExpiredPositionsAsync(PositionType positionType)
    {
        _logger.Information("Start removing expired position of type {PositionType} from database.", positionType);
        
        var result = await RemoveExpiredPositions(positionType);
        result.Switch(
            _ => _logger.Information("Successfully removed expired positions from database."),
            error => _logger.Error("Error while removing expired positions from database. Error: {Error}", error));
    }
    
    private async Task<Result<Success>> RemoveExpiredPositions(PositionType positionType)
    {
        var unitOfWork = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IUnitOfWork>();
        var positionService = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IPositionService>();

        var positionsQuery = await unitOfWork.Positions.FindAsync(p => p.Type == positionType);
        if (positionsQuery.TryTakeError(out var error, out var positions))
            return error;

        var productInfoQueries = new ConcurrentBag<(int PositionId, Result<TradeRepublicProductInfoDto> info)>();
        await positions.ParallelForEachAsync(async position =>
        {
            var productInfo = await _tradeRepublicApiService
                .MakeTrRequest<TradeRepublicProductInfoDto>(position.Isin.ToTradeRepublic().ProductInfo());

            productInfoQueries.Add((position.Id, productInfo));
        }, maxDegreeOfParallelism: 5);

        var failedProductInfos = productInfoQueries
            .Where(p => p.info.IsFailure)
            .Select(p => p.info);
        foreach (var productInfo in failedProductInfos)
            _logger.Error("Error while getting product info for position. Error: {Error}", productInfo.ErrorUnsafe);

        var productInfos = productInfoQueries
            .Where(p => p.info.IsSuccessful)
            .Select(p => new
            {
                p.PositionId,
                ProductInfo = p.info.ResultUnsafe
            })
            .ToList();
        
        var removedPositionResults = new ConcurrentBag<Result<Success>>();
        await productInfos.ParallelForEachAsync(async value =>
        {
            if (value.ProductInfo.Active!.Value)
                return;
            
            // TODO: N+1 query problem. This is not good.
            var usersQuery = await unitOfWork.Users.FirstAsync(u => u.Portfolio.Positions.Any(p => p.Id == value.PositionId));
            if (usersQuery.TryTakeError(out error, out var user))
            {
                removedPositionResults.Add(error);
                return;
            }
            
            _logger.Information("Removing expired position with ISIN {Isin} and Id {Id} from database.",
                value.ProductInfo.Isin, value.PositionId);
            
            // We can skip the validation here, since the job may run when the market is closed.
            var sellPositionResult = await positionService.SellPositionAsync(new BuyOrSellRequestDto
            {
                Isin = value.ProductInfo.Isin,
                NumberOfShares = positions.First(p => p.Id == value.PositionId).NumberOfShares,
            }, user.Uid, positionType, skipValidation: true);

            removedPositionResults.Add(
                sellPositionResult.Match<Result<Success>>(
                    _ => new Success(), 
                    err => err));
        }, maxDegreeOfParallelism: 5);
        
        var numberOfInactivePositions = productInfos.Count(p => !p.ProductInfo.Active!.Value);
        _logger.Information("Out of {Total} positions, {NumberOfExpiredPositions} positions were inactive " +
                            "i.e expired and {NumberOfRemovedPositions} positions were successfully removed from the database.",
            productInfos.Count, numberOfInactivePositions, removedPositionResults.Count(r => r.IsSuccessful));

        return new Success();
    }
}