using Application.Errors.Types;
using Application.Models.Dtos.HistoricalPosition.Response;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IHistoricalPositionsService
{
    public Task<Result<IEnumerable<HistoricalPositionResponseDto>>> GetHistoricalPositions(
        int userId, string uid);
}