using Application.Errors.Common;
using Application.Models.Dtos.Knockout.Response;
using Application.Models.Dtos.Shared.Common;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IKnockoutService
{
    public Task<OneOf<KnockoutPositionResponseDto, ErrorResponse>> GetKnockout(int id, string uid);
    public Task<OneOf<KnockoutPositionResponseDto, ErrorResponse>> BuyKnockout(BuyOrSellRequestDto dto, string uid);
    public Task<OneOf<KnockoutPositionResponseDto, ErrorResponse>> SellKnockout(BuyOrSellRequestDto dto, string uid);
}