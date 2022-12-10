using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Models.Dtos.TradeRepublic;
using Microsoft.Extensions.Configuration;
using static Application.Common.Shared;
using Success = OneOf.Types.Success;

namespace Application.Services.TradeRepublic;

public class TradeRepublicApiService : TradeRepublicApi, ITradeRepublicApiService
{
    public TradeRepublicApiService(IConfiguration configuration, IOngoingProductsService ongoingProductsService) : base(configuration, ongoingProductsService)
    {
    }

    private async Task<Result<Success>> IsStockMarketOpen(string isinWithExchangeExtension)
    {
        string content = "{\"type\":\"aggregateHistoryLight\",\"range\":\"1d\",\"id\":\""+ isinWithExchangeExtension + "\"}";
        var oneOfResult = await AddRequest<TradeRepublicIsStockMarketOpenResponseDto>(content, CancellationToken.None);
            
        var result = oneOfResult.Match<Models.Types.Result<bool>>(dto =>
        {
            if (!dto.ExpectedClosingTime.HasValue)
                return true;

            return DateTimeOffset.FromUnixTimeMilliseconds(dto.ExpectedClosingTime.Value) > DateTimeOffset.Now;
        }, error => error);

        if (result.TryPickT1(out var err, out var isStockMarketOpen))
            return err;

        if (!isStockMarketOpen)
            return StockMarketClosed.Default();

        return new Success();
    }

    public async Task<Result<T>> MakeTrRequest<T>(string requestString)
    {
        var cts = new CancellationTokenSource();
        T trResponse;
            
        try
        {
            cts.CancelAfter(1000 * 10);
            var oneOfResult =
                await AddRequest<T>(requestString, cts.Token);

            if (oneOfResult.TryPickT1(out var error, out trResponse))
                return error;
        }
        catch (OperationCanceledException e)
        {
            return TradeRepublicRequestTimeout.Default(requestString, e);
        }
        finally { cts.Dispose(); }

        return trResponse;
    }

    public async Task<Result<TradeRepublicProductInfoDto>> ValidateRequest(string isinWithoutExchangeExtension)
    {
        if ((await IsStockMarketOpen(isinWithoutExchangeExtension)).TryPickT1(out var errorResponse, out _))
            return errorResponse;

        if ((await MakeTrRequest<TradeRepublicProductInfoDto>(GetTradeRepublicProductInfoRequestString(ToIsinWithoutExchangeExtension(isinWithoutExchangeExtension))))
            .TryPickT1(out var errorResponse2, out var productInfo))
            return errorResponse2;

        if (productInfo.Active!.Value)
            return productInfo;
        
        const string message = "Product can not be bought or sold. This might happen if the product is expired or is knocked out.";
        return new InvalidOrder
        {
            Title = "Product can not be traded",
            Message = message,
            UserFriendlyMessage = message,
            AdditionalData = new {Isin = isinWithoutExchangeExtension}
        };
    }
}