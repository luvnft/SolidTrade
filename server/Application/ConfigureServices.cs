using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Database.Repositories;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.Cache;
using Application.Common.Interfaces.Services.Jobs;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Persistence.Database;
using Application.Persistence.Database.Repositories;
using Application.Services;
using Application.Services.Cache;
// using Application.Services.Jobs;
using Application.Services.TradeRepublic;
using Microsoft.Extensions.DependencyInjection;

namespace Application;

public static class ConfigureServices
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddSingleton<ICacheService, CacheService>();
        // services.AddSingleton<IBackgroundJob<RemoveKnockedOutProductsJob>, RemoveKnockedOutProductsJob>();
        // services.AddSingleton<IBackgroundJob<RemoveOngoingExpiredTradeJob>, RemoveOngoingExpiredTradeJob>();
        // services.AddSingleton<IBackgroundJob<CheckAndPerformStockSplitJob>, CheckAndPerformStockSplitJob>();
        // services.AddSingleton<IBackgroundJob<RemoveExpiredWarrantProductsJob>, RemoveExpiredWarrantProductsJob>();
        // services.AddSingleton<IBackgroundJob<RemoveUnusedProductImageRelationsJob>, RemoveUnusedProductImageRelationsJob>();
        services.AddSingleton<ITradeRepublicApiService, TradeRepublicApiService>();

        services.AddTransient<IUnitOfWork, UnitOfWork>();
        services.AddTransient<IUserRepository, UserRepository>();
        services.AddTransient<IPositionRepository, PositionRepository>();
        services.AddTransient<IPortfolioRepository, PortfolioRepository>();
        services.AddTransient<IStandingOrderRepository, StandingOrderRepository>();
        services.AddTransient<IStandingOrderHandlerService, StandingOrderHandlerService>();
        services.AddTransient<IHistoricalPositionRepository, HistoricalPositionRepository>();
        
        services.AddTransient<IUserService, UserService>();
        services.AddTransient<IPositionService, PositionService>();
        services.AddTransient<IPortfolioService, PortfolioService>();
        services.AddTransient<IProductImageService, ProductImageService>();
        services.AddTransient<IHistoricalPositionsService, HistoricalPositionsService>();

        return services;
    }
}