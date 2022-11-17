using Application.Errors.Common;
using Domain.Enums;
using OneOf;

namespace Application.Common.Interfaces.Services.TradeRepublic;

public interface ITradeRepublicApi
{
    public void AddOngoingRequest(string isin, PositionType positionType, int entityId);

    public Task<OneOf<T, UnexpectedError>> AddRequest<T>(string content, CancellationToken token);
}