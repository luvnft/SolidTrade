using Application.Errors.Types;
using Application.Models.Types;
using Domain.Enums;
using OneOf;

namespace Application.Common.Interfaces.Services.TradeRepublic;

public interface ITradeRepublicApi
{
    public void AddOngoingRequest(string isin, PositionType positionType, int entityId);

    public Task<Result<T>> AddRequest<T>(string content, CancellationToken token);
}