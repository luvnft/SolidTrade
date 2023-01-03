using Application.Models.Dtos.Position.Response;
using Application.Models.Dtos.Shared.Common;
using Domain.Enums;

namespace Application.Common.Interfaces.Services;

public interface IPositionService
{
    public Task<Result<PositionResponseDto>> GetPositionAsync(int id, string uid);
    public Task<Result<PositionResponseDto>> BuyPositionAsync(BuyOrSellRequestDto dto, string uid, PositionType type);
    public Task<Result<PositionResponseDto>> SellPositionAsync(BuyOrSellRequestDto dto, string uid, PositionType type);
}