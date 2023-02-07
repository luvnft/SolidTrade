using Application.Common;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Storage;
using Application.Common.Interfaces.Services.Cache;
using Application.Common.Interfaces.Services.Jobs;
using Application.Errors.Types;
using Application.Models.Dtos.ProductImage.Request;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Serilog;

namespace Application.Services.Jobs;

public class RemoveUnusedProductImageRelationsJob : IBackgroundJob<RemoveUnusedProductImageRelationsJob>
{
    public string JobTitle => "Remove unused product images relations";
    
    private readonly ILogger _logger = Log.ForContext<RemoveUnusedProductImageRelationsJob>();
    private readonly IServiceScopeFactory _scopeFactory;
        
    public RemoveUnusedProductImageRelationsJob(IServiceScopeFactory scopeFactory)
    {
        _scopeFactory = scopeFactory;
    }
        
    public Task StartAsync()
    {
        try
        {
            _logger.Information("Removing unused product image relations from database");
            return RemoveUnusedProductImageRelationsAsync();
        }
        catch (Exception e)
        {
            _logger.Error(ApplicationConstants.LogMessageTemplate, new UnexpectedError
            {
                Title = "Could not remove product image relations",
                Message = "Something went wrong trying to remove expired trades. See exception for more.",
                Exception = e,
            });
            return Task.CompletedTask;
        }
    }

    private async Task RemoveUnusedProductImageRelationsAsync()
    {
        var mediaManagementService = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IMediaManagementService>();
        await using var database = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<IApplicationDbContext>();
        var cache = _scopeFactory.CreateScope().ServiceProvider.GetRequiredService<ICacheService>();

        var productImageRelations = await database.ProductImageRelations.AsQueryable().ToListAsync();

        int countOfSuccessfulDeletions = 0, countOfUnusedProductImageRelations = 0;

        foreach (var productImageRelation in productImageRelations)
        {
            if (await CheckIfImageRelationsIsUnused(database, productImageRelation))
            {
                countOfUnusedProductImageRelations++;
                    
                var deletionResult = await mediaManagementService.DeleteImage(productImageRelation.CorrespondingImageUrl);

                if (deletionResult.TryPickT1(out var error, out _))
                {
                    _logger.Warning(ApplicationConstants.LogMessageTemplate, error);
                    continue;
                }

                database.ProductImageRelations.Remove(productImageRelation);
                countOfSuccessfulDeletions++;
            }
        }
            
        // Because the cache service might still have references to images that have been deleted, we remove all cached GetProductImageRequestDto to ensure that the cache does not return
        // image urls who's image does not exist anymore.
        // The type GetProductImageRequestDto is the type being cached. This is why we use GetProductImageRequestDto instead of ProductImageRelation.
        cache.Clear<GetProductImageRequestDto>();
        await database.SaveChangesAsync();
        _logger.Information(
            "There are {@CountOfUnusedProductImageRelations} unused product images and {@CountOfSuccessfulDeletions} product images were successfully deleted from database",
            countOfUnusedProductImageRelations, countOfSuccessfulDeletions);
    }

    private static async Task<bool> CheckIfImageRelationsIsUnused(IApplicationDbContext db, ProductImageRelation relation)
        => !await db.Positions.AnyAsync(k => k.Isin == relation.Isin);
}