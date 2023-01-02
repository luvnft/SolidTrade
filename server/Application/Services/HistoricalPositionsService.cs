using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Models.Dtos.HistoricalPosition.Response;
using AutoMapper;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Serilog;

namespace Application.Services;

public class HistoricalPositionsService : IHistoricalPositionsService
{
    private readonly ILogger _logger = Log.ForContext<HistoricalPositionsService>();
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public HistoricalPositionsService(IUnitOfWork unitOfWork, IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }

    public async Task<Result<IEnumerable<HistoricalPositionResponseDto>>> GetHistoricalPositions(int userId, string uid)
    {
        var userResult = await _unitOfWork.Users.FindByIdAsync(userId);

        if (userResult.TryTakeError(out var error, out var user))
            return error;

        if (!user.HasPublicPortfolio && user.Uid != uid)
            return NotAuthorized.PrivatePortfolio();
            
        var historicalPositionsResult = await _unitOfWork.HistoricalPositions.FindAsync(x => x.UserId == userId);

        if (historicalPositionsResult.TryTakeError(out error, out var historicalPositions))
            return error;
            
        _logger.Information("User with user uid {@Uid} fetched portfolio with user id {@UserId} successfully", uid, userId);

        return _mapper.Map<List<HistoricalPosition>, List<HistoricalPositionResponseDto>>(historicalPositions);
    }
}