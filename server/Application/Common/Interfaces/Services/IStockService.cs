using Application.Errors.Common;
using Application.Models.Dtos.Shared.Common;
using Application.Models.Dtos.Stock.Response;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IStockService
{
    public Task<OneOf<StockPositionResponseDto, ErrorResponse>> GetStock(int id, string uid);

    public Task<OneOf<StockPositionResponseDto, ErrorResponse>> BuyStock(BuyOrSellRequestDto dto, string uid);

    public Task<OneOf<StockPositionResponseDto, ErrorResponse>> SellStock(BuyOrSellRequestDto dto, string uid);
}