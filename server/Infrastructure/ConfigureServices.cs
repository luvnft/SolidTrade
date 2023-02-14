using System.IdentityModel.Tokens.Jwt;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Storage;
using Application.Common.Interfaces.Services;
using Infrastructure.Authentication;
using Infrastructure.Configurations;
using Infrastructure.Persistence.Database;
using Infrastructure.Persistence.Storage;
using Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;

namespace Infrastructure;

public static class ConfigureServices
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<IApplicationDbContext, ApplicationDbContext>(options =>
        {
            options.UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking);
        });
        
        services.AddTransient<IAuthenticationService, AuthenticationService>();
        services.AddTransient<INotificationService, NotificationService>();
        services.AddSingleton(configuration.GetSection("Email").Get<EmailConfiguration>());
        services.AddSingleton<IMediaManagementService, MediaManagementService>();
        
        var secretKey = configuration.GetValue<string>("Jwt:Key");
        
        var securityKey = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(secretKey));
        var signingCredentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256Signature);
        var jwtHeader = new JwtHeader(signingCredentials);

        services.AddSingleton(securityKey);
        services.AddSingleton(jwtHeader);
        
        return services;
    }
}