using System;
using System.Collections;
using System.Collections.Generic;
using Microsoft.Extensions.Configuration;

namespace SolidTradeServer.Common.Extensions
{
    public static class ConfigurationBuilderExtensions
    {
        public static IConfigurationBuilder AddAndParseDotEnv(this IConfigurationBuilder configurationBuilder)
        {
            var config = ParseAppSettingsFromDotEnv();
            
            configurationBuilder.AddInMemoryCollection(config);
            return configurationBuilder;
        }

        private static Dictionary<string, string> ParseAppSettingsFromDotEnv()
        {
            var appSettings = new Dictionary<string, string>();
            
            var environmentVariables = Environment.GetEnvironmentVariables();
            const string configPrefix = "APP_CONFIG_";
            
            foreach (DictionaryEntry entry in environmentVariables)
            {
                var key = (string) entry.Key;
                if (!key.StartsWith(configPrefix))
                    continue;
                
                appSettings.Add(key[configPrefix.Length..].Replace('_', ':'), entry.Value!.ToString());
            }
            
            return appSettings;
        }
    }
}