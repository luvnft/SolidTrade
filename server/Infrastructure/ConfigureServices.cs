using Application.Common.Interfaces.Persistence;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Storage;
using Application.Common.Interfaces.Services;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Infrastructure.Identity;
using Infrastructure.Persistence.Database;
using Infrastructure.Persistence.Storage;
using Infrastructure.Services;
using Microsoft.AspNetCore.Builder;
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

    public static IApplicationBuilder ConfigureInfrastructure(this IApplicationBuilder app, IConfiguration configuration)
    {
        // For local development environments we use the firebase emulator for authentication.
        // var firebaseAuthEmulatorHost = configuration.GetValue<string>("FirebaseAuthEmulatorHost");
        // if (firebaseAuthEmulatorHost != null)
        //     Environment.SetEnvironmentVariable("FIREBASE_AUTH_EMULATOR_HOST", firebaseAuthEmulatorHost);
        //
        // FirebaseApp.Create(new AppOptions
        // {
        //     Credential = GoogleCredential.FromFile(configuration["FirebaseCredentials"]),
        // });

        return app;
    }
}