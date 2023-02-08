using Domain.Enums;

namespace Application.Extensions;

public static class ProductImageThemeColorExtensions
{
    public static string CreateIdentifier(this ProductImageThemeColor themeColor, string isinWithoutExchangeExtension)
        => $"{isinWithoutExchangeExtension}-{themeColor}";
}