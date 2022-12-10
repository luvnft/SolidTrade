using Application.Errors.Types;
using Application.Models.Dtos.Shared.Common;
using Application.Models.Dtos.Stock.Response;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IStockService
{
    public Task<Result<StockPositionResponseDto>> GetStock(int id, string uid);
    public Task<Result<StockPositionResponseDto>> BuyStock(BuyOrSellRequestDto dto, string uid);
    public Task<Result<StockPositionResponseDto>> SellStock(BuyOrSellRequestDto dto, string uid);
}