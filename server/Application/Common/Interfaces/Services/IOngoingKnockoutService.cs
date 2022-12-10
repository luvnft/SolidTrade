using Application.Errors.Types;
using Application.Models.Dtos.OngoingKnockout.Response;
using Application.Models.Dtos.Shared.OngoingPosition.Request;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IOngoingKnockoutService
{
    public Task<Result<OngoingKnockoutPositionResponseDto>> GetOngoingKnockout(int id, string uid);
    public Task<Result<OngoingKnockoutPositionResponseDto>> OpenOngoingKnockout(OngoingPositionRequestDto dto, string uid);
    public Task<Result<OngoingKnockoutPositionResponseDto>> CloseOngoingKnockout(
        CloseOngoingPositionRequestDto dto, string uid);
}