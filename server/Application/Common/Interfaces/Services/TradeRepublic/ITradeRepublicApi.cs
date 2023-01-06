namespace Application.Common.Interfaces.Services.TradeRepublic;

public interface ITradeRepublicApi
{
    public void AddStandingOrder(string isin, int entityId);

    public Task<Result<T>> AddRequest<T>(string content, CancellationToken token);
}