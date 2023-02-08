using Domain.Common.Position;

namespace Application.Common;

public static class Utilities
{
    public static (decimal NumberOfShares, decimal BuyInPrice) CalculateNewPosition(IPosition p1, IPosition p2)
    {
        var numberOfShares = p1.NumberOfShares + p2.NumberOfShares;

        var buyInPrice =
            (p1.BuyInPrice * p1.NumberOfShares + p2.BuyInPrice * p2.NumberOfShares) / numberOfShares;

        return (numberOfShares, buyInPrice);
    }
}