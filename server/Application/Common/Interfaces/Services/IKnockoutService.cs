using Application.Errors.Types;
using Application.Models.Dtos.Knockout.Response;
using Application.Models.Dtos.Shared.Common;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IKnockoutService
{
    public Task<Result<KnockoutPositionResponseDto>> GetKnockout(int id, string uid);
    public Task<Result<KnockoutPositionResponseDto>> BuyKnockout(BuyOrSellRequestDto dto, string uid);
    public Task<Result<KnockoutPositionResponseDto>> SellKnockout(BuyOrSellRequestDto dto, string uid);
}