using Application.Errors.Common;
using Application.Models.Dtos.HistoricalPosition.Response;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IHistoricalPositionsService
{
    public Task<OneOf<IEnumerable<HistoricalPositionResponseDto>, ErrorResponse>> GetHistoricalPositions(
        int userId, string uid);
}