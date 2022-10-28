using Application.Errors.Common;
using Application.Models.Dtos.OngoingWarrant.Response;
using Application.Models.Dtos.Shared.OngoingPosition.Request;

namespace Application.Common.Interfaces.Services;
using OneOf;

public interface IOngoingWarrantService
{
    public Task<OneOf<OngoingWarrantPositionResponseDto, ErrorResponse>> GetOngoingWarrant(int id, string uid);

    public Task<OneOf<OngoingWarrantPositionResponseDto, ErrorResponse>> OpenOngoingWarrant(
        OngoingPositionRequestDto dto, string uid);

    public Task<OneOf<OngoingWarrantPositionResponseDto, ErrorResponse>> CloseOngoingWarrant(
        CloseOngoingPositionRequestDto dto, string uid);
}
