using Application.Errors.Types;
using Application.Models.Dtos.TradeRepublic;
using OneOf; 

namespace Application.Common.Interfaces.Services.TradeRepublic;

public interface ITradeRepublicApiService : ITradeRepublicApi
{
    public Task<Result<T>> MakeTrRequest<T>(string requestString);
    public Task<Result<TradeRepublicProductInfoDto>> ValidateRequest(string isinWithoutExchangeExtension);
}