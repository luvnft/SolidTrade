using Application.Errors.Common;
using Application.Models.Dtos.TradeRepublic;
using OneOf; 

namespace Application.Common.Interfaces.Services.TradeRepublic;

public interface ITradeRepublicApiService : ITradeRepublicApi
{
    public Task<OneOf<T, ErrorResponse>> MakeTrRequest<T>(string requestString);

    public Task<OneOf<TradeRepublicProductInfoDto, ErrorResponse>> ValidateRequest(
        string isinWithoutExchangeExtension);
}