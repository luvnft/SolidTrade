using Microsoft.Extensions.Configuration;

namespace Infrastructure.Extensions;

public static class ConfigurationBuilderExtensions
{
    public static IConfigurationBuilder AddJsonConfigurationFiles(this IConfigurationBuilder builder, string path)
    {
        builder
            .AddJsonFile($"{path}appsettings.json")
            .AddJsonFile($"{path}appsettings.Development.credentials.json", optional: true)
            .AddJsonFile($"{path}appsettings.credentials.json", optional: true);
        return builder;
    }
}