using Application.Errors.Common;
using Application.Models.Dtos.OngoingKnockout.Response;
using Application.Models.Dtos.Shared.OngoingPosition.Request;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IOngoingKnockoutService
{
    public Task<OneOf<OngoingKnockoutPositionResponseDto, ErrorResponse>> GetOngoingKnockout(int id, string uid);
    public Task<OneOf<OngoingKnockoutPositionResponseDto, ErrorResponse>> OpenOngoingKnockout(OngoingPositionRequestDto dto, string uid);

    public Task<OneOf<OngoingKnockoutPositionResponseDto, ErrorResponse>> CloseOngoingKnockout(
        CloseOngoingPositionRequestDto dto, string uid);
}