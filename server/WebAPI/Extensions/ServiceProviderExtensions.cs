namespace WebAPI.Extensions;

public static class ServiceProviderExtensions
{
    public static T GetServiceOrThrow<T>(this IServiceProvider provider)
        => provider.GetService<T>() ?? throw new Exception($"The service '{nameof(T)}' could not be provided.");
}