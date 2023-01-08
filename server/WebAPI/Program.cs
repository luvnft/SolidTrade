using System.Runtime.InteropServices;
using Application.Common.Interfaces.Persistence.Database;
using Infrastructure.Extensions;
using Serilog;
using Serilog.Events;
using Serilog.Sinks.Elasticsearch;
using WebAPI.Serilog;

namespace WebAPI;

public static class Program
{
    private const string SerilogOutputTemplate =
        "{Timestamp:yyyy'-'MM'-'dd'T'HH':'mm':'ss.ffffff zzz} [{Level:u3}] {SourceContext} - {Message:lj}{NewLine}{Exception}";

    [STAThread]
    public static void Main(string[] args)
    {
        var host = CreateHostBuilder(args)
            .Build()
            .MigrateDatabase<IApplicationDbContext>();

        host.Run();
    }

    private static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureHostConfiguration(hostConfig =>
            {
                hostConfig.AddJsonConfigurationFiles("./Configuration/");
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
                        (date, wt) =>
                            wt.File(RuntimeInformation.IsOSPlatform(OSPlatform.Windows)
                                    ? $"./Logs/{date:MM-yyyy}/log-{date:dd-MM-yyyy ddd zz} - .log"
                                    : $"/var/log/solidtrade/api/{date:MM-yyyy}/log-{date:dd-MM-yyyy ddd zz} - .log",
                                outputTemplate: SerilogOutputTemplate,
                                fileSizeLimitBytes: 2000000,
                                rollingInterval: RollingInterval.Day,
                                rollOnFileSizeLimit: true))
                    .WriteTo.Console(
                        outputTemplate: SerilogOutputTemplate,
                        restrictedToMinimumLevel: LogEventLevel.Information)
                    .WriteTo.Conditional(_ => context.Configuration.GetValue<bool>("ElasticConfiguration:Enable"), c =>
                        c.Elasticsearch(
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
}