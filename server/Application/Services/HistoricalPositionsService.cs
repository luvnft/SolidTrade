using System.Net;
using Application.Common.Interfaces.Persistence;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Errors.Common;
using Application.Models.Dtos.HistoricalPosition.Response;
using AutoMapper;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using OneOf;
using Serilog;

namespace Application.Services;

public class HistoricalPositionsService : IHistoricalPositionsService
{
    private readonly ILogger _logger = Log.ForContext<HistoricalPositionsService>();
    private readonly IApplicationDbContext _database;
    private readonly IMapper _mapper;

    public HistoricalPositionsService(IApplicationDbContext database, IMapper mapper)
    {
        _database = database;
        _mapper = mapper;
    }

    public async Task<OneOf<IEnumerable<HistoricalPositionResponseDto>, ErrorResponse>> GetHistoricalPositions(int userId, string uid)
    {
        var user = await _database.Users.FindAsync(userId);

        if (user is null)
        {
            return new ErrorResponse(new NotFound
            {
                Title = "User not found",
                Message = $"Could not find user with id: {userId}",
            }, HttpStatusCode.NotFound);
        }
            
        if (!user.HasPublicPortfolio && user.Uid != uid)
        {
            return new ErrorResponse(new NotAuthorized
            {
                Title = "Portfolio is private",
                Message = "Tried to access other user's portfolio",
            }, HttpStatusCode.Unauthorized);
        }

        var historicalPositions = await _database.HistoricalPositions
            .AsQueryable()
            .Where(p => p.UserId == userId)
            .ToListAsync();
            
        _logger.Information("User with user uid {@Uid} fetched portfolio with user id {@UserId} successfully", uid, userId);

        return _mapper.Map<List<HistoricalPosition>, List<HistoricalPositionResponseDto>>(historicalPositions);
    }
}