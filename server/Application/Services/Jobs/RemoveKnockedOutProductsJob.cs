﻿using Application.Common;
using Application.Common.Interfaces.Persistence;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services.Jobs;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Errors;
using Application.Errors.Types;
using Application.Models.Dtos.TradeRepublic;
using Domain.Entities;
using Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using OneOf;
using Serilog;

namespace Application.Services.Jobs;

public class RemoveKnockedOutProductsJob : IBackgroundJob<RemoveKnockedOutProductsJob>
{
    public string JobTitle => "Remove Knocked out products";
    
    private readonly ILogger _logger = Log.ForContext<RemoveKnockedOutProductsJob>();
    private readonly ITradeRepublicApiService _tradeRepublicApiService;
    private readonly IServiceScopeFactory _scopeFactory;

    public RemoveKnockedOutProductsJob(ITradeRepublicApiService tradeRepublicApiService, IServiceScopeFactory scopeFactory)
    {
        _tradeRepublicApiService = tradeRepublicApiService;
        _scopeFactory = scopeFactory;
    }
        
    public Task StartAsync()
    {
        try
        {
            _logger.Information("Removing knocked out products from database.");
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
            
        var knockoutPositions = await database.KnockoutPositions.Include(k => k.Portfolio).AsQueryable().ToListAsync();
        var tasks = new List<Task<Result<TradeRepublicProductInfoDto>>>();
            
        foreach (var knockoutPosition in knockoutPositions)
        {
            tasks.Add(_tradeRepublicApiService.MakeTrRequest<TradeRepublicProductInfoDto>(
                Shared.GetTradeRepublicProductInfoRequestString(knockoutPosition.Isin)));
        }
            
        var results = await Task.WhenAll(tasks);

        var trProductInfos = results.Where(oneOfResult => oneOfResult.IsT0).Select(oneOfResult => oneOfResult.AsT0);
        var errors = results.Where(oneOfResult => oneOfResult.IsT1).Select(oneOfResult => oneOfResult.AsT1).ToList();

        if (errors.Any())
        {
            foreach (var error in errors)
                _logger.Warning(ApplicationConstants.LogMessageTemplate, error);
            return;
        }

        var historicalPositions = new List<HistoricalPosition>();
        foreach (var trProductInfo in trProductInfos)
        {
            var knockoutPosition = knockoutPositions.Find(k => k.Isin == trProductInfo.Isin);
            if (trProductInfo.Active.HasValue && !trProductInfo.Active.Value)
            {
                var historicalPosition = new HistoricalPosition
                {
                    Isin = knockoutPosition!.Isin,
                    NumberOfShares = knockoutPosition.NumberOfShares,
                    UserId = knockoutPosition.Portfolio.UserId,
                    PositionType = PositionType.Knockout,
                    BuyOrSell = BuyOrSell.Sell,
                    Performance = 0,
                    BuyInPrice = 0,
                };
                    
                historicalPositions.Add(historicalPosition);
            }
            else
                knockoutPositions.Remove(knockoutPosition);
        }

        database.HistoricalPositions.AddRange(historicalPositions);
        database.KnockoutPositions.RemoveRange(knockoutPositions);

        try
        {
            await database.SaveChangesAsync();
            _logger.Information("Removed {@knockoutPositions} knocked out items from database.", knockoutPositions.Count);
        }
        catch (Exception e)
        {
            var error = new UnexpectedDatabaseError
            {
                Title = "Failed to save removed knockouts",
                Message = "Failed to save removed knockouts.",
                Exception = e,
                AdditionalData = new { Knockouts = knockoutPositions },
            };
                
            _logger.Warning(ApplicationConstants.LogMessageTemplate, error);
        }
    }
}