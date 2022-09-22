using System;
using System.Linq;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog.Sinks.Elasticsearch;
using Serilog;
using Serilog.Debugging;
using Serilog.Events;
using SolidTradeServer.Common;
using SolidTradeServer.Data.Common;
using SolidTradeServer.Data.Models.Errors;
using SolidTradeServer.Serilog;

namespace SolidTradeServer
{
    public static class Program
    {
        private const string SerilogOutputTemplate =
            "{Timestamp:yyyy'-'MM'-'dd'T'HH':'mm':'ss.ffffff zzz} [{Level:u3}] {SourceContext} - {Message:lj}{NewLine}{Exception}";
        private static readonly ILogger _logger = Log.ForContext(typeof(Program));
        
        public static void Main(string[] args)
        {
            var host = CreateHostBuilder(args)
                .Build()
                .MigrateDatabase<DbSolidTrade>();

            SelfLog.Enable(_logger.Error);
            
            host.Run();
        }

        private static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureHostConfiguration(hostConfig =>
                {
                    hostConfig.AddJsonFile("config/appsettings.json");
                    hostConfig.AddJsonFile("config/appsettings.credentials.json");
                    hostConfig.AddEnvironmentVariables();
                })
                .UseSerilog((context, configuration) =>
                {
                    configuration
                        .MinimumLevel.Debug()
                        .Enrich.FromLogContext()
                        .Enrich.WithMachineName()
                        .Enrich.WithProperty("Environment", context.HostingEnvironment.EnvironmentName)
                        .Enrich.With(new SerilogMessageEnricher())
                        .WriteTo.Map(_ => DateTimeOffset.Now,
                            (v, wt) =>
                                wt.File($"/var/log/solidtrade/api/{v:MM-yyyy}/log-{v:dd-MM-yyyy ddd zz} - .log",
                                    outputTemplate: SerilogOutputTemplate,
                                    fileSizeLimitBytes: 2000000,
                                    rollingInterval: RollingInterval.Day,
                                    rollOnFileSizeLimit: true))
                        .WriteTo.Console(
                            outputTemplate: SerilogOutputTemplate,
                            restrictedToMinimumLevel: LogEventLevel.Information)
                        .WriteTo.Conditional(_ => context.Configuration.GetValue<bool>("ElasticConfiguration:Enable"), c => c.Elasticsearch(
                            new ElasticsearchSinkOptions(new Uri(context.Configuration["ElasticConfiguration:Uri"]))
                            {
                                ModifyConnectionSettings = x =>
                                    x.BasicAuthentication(context.Configuration["ElasticConfiguration:Username"], 
                                        context.Configuration["ElasticConfiguration:Password"]),
                                IndexFormat =
                                    $"{context.Configuration["ElasticConfiguration:ApplicationName"]}-logs-{context.HostingEnvironment.EnvironmentName?.ToLower().Replace('.', '-')}-{DateTime.UtcNow:MM-yyyy}",
                                AutoRegisterTemplate = true,
                                NumberOfShards = 2,
                                NumberOfReplicas = 1,
                                MinimumLogEventLevel = LogEventLevel.Information,
                            }))
                        .ReadFrom.Configuration(context.Configuration);
                })
                .ConfigureWebHostDefaults(webBuilder => { webBuilder.UseStartup<Startup>(); });

        public static void ExitApplication() => Environment.Exit(-1);
        
        private static IHost MigrateDatabase<T>(this IHost host) where T : DbContext
        {
            using var scope = host.Services.CreateScope();
            var services = scope.ServiceProvider;
            try
            {
                var db = services.GetRequiredService<T>();
                var pendingMigrations = db.Database.GetPendingMigrations().ToList();

                _logger.Information("Checking for pending migrations.");
                if (!pendingMigrations.Any())
                {
                    _logger.Information("Found no pending migrations.");
                    return host;
                }
                
                _logger.Information("Detected pending migrations. {@PendingMigrations}.", string.Join(", ", pendingMigrations));

                var backupFileName = $"{DateTimeOffset.Now:dd-MM-yyyy hh-mm-ss zz} - {pendingMigrations.Last()}.bak";
                var backupFilePath = $"./database_backups/{backupFileName}";
                
                _logger.Information("Trying to create backup file with name {@BackupFileName}.", backupFileName);
                db.Database.ExecuteSqlRaw($"Backup database master to disk='{backupFilePath}'");
                _logger.Information("Created backup successfully in directory: {@BackupFilePath}.", backupFilePath);
                
                _logger.Information("Trying to apply pending migrations.");
                db.Database.Migrate();
                _logger.Information("Applied migrations successfully.");
            }
            catch (Exception e)
            {
                _logger.Fatal(Shared.LogMessageTemplate, new UnexpectedError
                {
                    Title = "Failed to migrating database",
                    Message = "An error occurred while migrating the database. Stopping application.",
                    Exception = e,
                });
                ExitApplication();
            }

            return host;
        }
    }
}