using Application.Models.Dtos.OngoingWarrant.Response;
using Application.Models.Dtos.Shared.OngoingPosition.Request;

namespace Application.Common.Interfaces.Services;

public interface IOngoingWarrantService
{
    public Task<Result<OngoingWarrantPositionResponseDto>> GetOngoingWarrant(int id, string uid);
    public Task<Result<OngoingWarrantPositionResponseDto>> OpenOngoingWarrant(
        OngoingPositionRequestDto dto, string uid);
    public Task<Result<OngoingWarrantPositionResponseDto>> CloseOngoingWarrant(
        CloseOngoingPositionRequestDto dto, string uid);
}
