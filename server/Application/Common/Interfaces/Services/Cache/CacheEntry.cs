namespace Application.Common.Interfaces.Services.Cache;

/// <summary>
/// Contains information about the cache.
/// </summary>
/// <typeparam name="T">Represents the type of the cache.</typeparam>
public struct CacheEntry<T>
{
    /// <summary>
    /// Gets or sets a value indicating whether the the cache is expired or not. Even if there was never a cache entry, this value will be true.
    /// </summary>
    public bool Expired { get; set; }

    /// <summary>
    /// Gets or sets the cached value.
    /// </summary>
    public T Value { get; set; }
}