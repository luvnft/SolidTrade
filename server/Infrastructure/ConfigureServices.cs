using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Storage;
using Application.Common.Interfaces.Services;
using Infrastructure.Identity;
using Infrastructure.Persistence.Database;
using Infrastructure.Persistence.Storage;
using Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Infrastructure;

public static class ConfigureServices
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<IApplicationDbContext, ApplicationDbContext>(options =>
        {
            options.UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking);
        });
        
        services.AddTransient<IIdentityService, IdentityService>();
        services.AddTransient<INotificationService, NotificationService>();
        services.AddSingleton<IMediaManagementService, MediaManagementService>();
        
        var url = configuration.GetValue<string>("Supabase:Url");
        var key = configuration.GetValue<string>("Supabase:Key");

        var client = new Supabase.Client(url, key);
        // Since we cant await while configuring services we have to call the wait method for the client to initialize.
        client.InitializeAsync().Wait();
        
        services.AddSingleton(client);
        
        return services;
    }
}