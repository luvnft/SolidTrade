using Application.Common;
using Application.Common.Interfaces.Persistence;
using Application.Common.Interfaces.Persistence.Database;
using Application.Errors;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;

namespace Infrastructure.Extensions;

public static class PersistenceExtensions
{
    private static readonly ILogger Logger = Log.ForContext(typeof(PersistenceExtensions));
    
    public static IHost MigrateDatabase<T>(this IHost host) where T : IApplicationDbContext 
    {
        using var scope = host.Services.CreateScope();
        var services = scope.ServiceProvider;
        try
        {
            var db = services.GetRequiredService<T>();
            var pendingMigrations = db.Database.GetPendingMigrations().ToList();

            Logger.Information("Checking for pending migrations.");
            if (!pendingMigrations.Any())
            {
                Logger.Information("Found no pending migrations.");
                return host;
            }

            Logger.Information("Detected pending migrations. {@PendingMigrations}.",
                string.Join(", ", pendingMigrations));

            var backupFileName = $"{DateTimeOffset.Now:dd-MM-yyyy hh-mm-ss zz} - {pendingMigrations.Last()}.bak";
            var backupFilePath = $"./database_backups/{backupFileName}";

            Logger.Information("Trying to create backup file with name {@BackupFileName}.", backupFileName);
            db.Database.ExecuteSqlRaw($"Backup database master to disk='{backupFilePath}'");
            Logger.Information("Created backup successfully in directory: {@BackupFilePath}.", backupFilePath);

            Logger.Information("Trying to apply pending migrations.");
            db.Database.Migrate();
            Logger.Information("Applied migrations successfully.");
        }
        catch (Exception e)
        {
            Logger.Fatal(ApplicationConstants.LogMessageTemplate, new UnexpectedError
            {
                Title = "Failed to migrating database",
                Message = "An error occurred while migrating the database. Stopping application.",
                Exception = e,
            });
            
            Environment.Exit(-1);
        }

        return host;
    }
}