using System.Text.Json;
using System.Text.Json.Serialization;
using Application;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services.Jobs;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Errors.Types;
using Application.Models.MappingProfiles;
using Application.Services.Jobs;
using Hangfire;
using Hangfire.Dashboard.BasicAuthorization;
using Infrastructure;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using WebAPI.Converters;
using WebAPI.Extensions;
using WebAPI.Filters;

namespace WebAPI;

public class Startup
{
    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    public IConfiguration Configuration { get; }
 
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddLogging();
        services.AddAutoMapper(typeof(EntityToResponseDtoProfile));

        services.AddInfrastructureServices();
        services.AddApplicationServices();

        services.AddControllers(options =>
        {
            options.Filters.Add<AuthenticationFilter>();
        }).AddJsonOptions(options =>
        {
            options.JsonSerializerOptions.ReadCommentHandling = JsonCommentHandling.Skip;
            options.JsonSerializerOptions.Converters.Add(new DecimalJsonConverter());
            options.JsonSerializerOptions.Converters.Add(new StringRemoveWhitespaceConverter());
            options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter(null, false));
        });
            
        services.Configure<ApiBehaviorOptions>(apiBehaviorOptions =>
            apiBehaviorOptions.InvalidModelStateResponseFactory = 
                actionContext => new BadRequestObjectResult(new InvalidRequestDto
                {
                    Title = "Validation error",
                    Message = "Something went wrong validating request.",
                    UserFriendlyMessage = actionContext.GetUserFriendlyValidationError(),
                }));

        services.AddHangfire(config =>
            config.SetDataCompatibilityLevel(CompatibilityLevel.Version_170)
                .UseSimpleAssemblyNameTypeSerializer()
                .UseDefaultTypeSerializer()
                .UseSqlServerStorage(Configuration.GetConnectionString("SqlServerConnection")));

        services.AddHangfireServer();
    }

    public void Configure(IApplicationBuilder app,
        IWebHostEnvironment env,
        IRecurringJobManager recurringJobManager,
        IServiceProvider serviceProvider,
        IApplicationDbContext context)
    {
        context.Database.EnsureCreated();
                    
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }
        
        app.Use((httpContext, next) =>
        {
            httpContext.Response.Headers.Add("Access-Control-Allow-Origin", "*");
            httpContext.Response.Headers.Add("Access-Control-Allow-Headers", "*");
            httpContext.Response.Headers.Add("Access-Control-Allow-Methods", "*");
            
            if (httpContext.Request.Method != "OPTIONS")
                return next();
            
            httpContext.Response.StatusCode = 204;
            return Task.CompletedTask;
        });
            
        app.UseRouting();

        app.UseExceptionHandler(a => a.Run(async httpContext =>
        {
            var exceptionHandlerPathFeature = httpContext.Features.Get<IExceptionHandlerPathFeature>();
            var e = exceptionHandlerPathFeature.Error;

            var result = JsonConvert.SerializeObject(new UnexpectedError
            {
                Title = "Unexpected error",
                Message = e.Message,
                Exception = env.IsDevelopment() ? e : null,
            });
            httpContext.Response.ContentType = "application/json";
            await httpContext.Response.WriteAsync(result).ConfigureAwait(false);
        }));
            
        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers();
        });

        var filter = new BasicAuthAuthorizationFilter(
            new BasicAuthAuthorizationFilterOptions
            {
                // Because we are using nginx as a reverse proxy, ssl will not be required
                RequireSsl = false,
                SslRedirect = false,
                // Case sensitive login checking
                LoginCaseSensitive = true,
                Users = new[]
                {
                    new BasicAuthAuthorizationUser
                    {
                        Login = Configuration["Hangfire:User"],
                        PasswordClear = Configuration["Hangfire:Password"],
                    },
                }
            });

        if (!env.IsDevelopment())
        {
            app.UseHangfireDashboard(options: new DashboardOptions
            {
                Authorization = new [] { filter }
            });
        }

        var removeOngoingExpiredTradeJob = serviceProvider.GetRequiredService<IBackgroundJob<RemoveOutDatesStandingOrdersJob>>();
        var checkAndPerformStockSplitJob = serviceProvider.GetRequiredService<IBackgroundJob<CheckAndPerformStockSplitJob>>();
        var removeExpiredWarrantProductsJob = serviceProvider.GetRequiredService<IBackgroundJob<RemoveExpiredPositionsJob>>();
        var removeUnusedProductImageRelationsJob = serviceProvider.GetRequiredService<IBackgroundJob<RemoveUnusedProductImageRelationsJob>>();
            
        recurringJobManager.AddOrUpdate(removeOngoingExpiredTradeJob.JobTitle, () => removeOngoingExpiredTradeJob.StartAsync(), Cron.Daily);
        recurringJobManager.AddOrUpdate(removeExpiredWarrantProductsJob.JobTitle, () => removeExpiredWarrantProductsJob.StartAsync(), Cron.Weekly(DayOfWeek.Sunday));
        recurringJobManager.AddOrUpdate(checkAndPerformStockSplitJob.JobTitle, () => checkAndPerformStockSplitJob.StartAsync(), Cron.Daily);
        recurringJobManager.AddOrUpdate(removeUnusedProductImageRelationsJob.JobTitle, () => removeUnusedProductImageRelationsJob.StartAsync(), Cron.Weekly(DayOfWeek.Sunday));
  
        // Ensures the trade republic service is being instantiated at the beginning of the application.
        app.ApplicationServices.GetService<ITradeRepublicApiService>();

        app.ConfigureInfrastructure(Configuration);
    }
}