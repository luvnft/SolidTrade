using System.Net;
using Application.Common.Interfaces.Persistence;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Errors;
using Application.Errors.Common;
using Application.Models.Dtos.Portfolio.Request;
using Application.Models.Dtos.Portfolio.Response;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using OneOf;
using Serilog;
using static Application.Common.Shared;
using static Application.Common.ApplicationConstants;

namespace Application.Services;

public class PortfolioService : IPortfolioService
{
    private readonly ILogger _logger = Log.ForContext<PortfolioService>();
        
    private readonly IApplicationDbContext _database;
    private readonly IMapper _mapper;

    public PortfolioService(IApplicationDbContext database, IMapper mapper)
    {
        _database = database;
        _mapper = mapper;
    }

    public async Task<OneOf<PortfolioResponseDto, ErrorResponse>> GetPortfolio(GetPortfolioRequestDto dto, string uid)
    {
        var query = _database.Portfolios
            .Include(p => p.User)
            .Include(p => p.WarrantPositions)
            .Include(p => p.StockPositions)
            .Include(p => p.KnockOutPositions)
            .Include(p => p.OngoingWarrantPositions)
            .Include(p => p.OngoingKnockOutPositions);

        if (dto.PortfolioId.HasValue)
        {
            var portfolio = await query.FirstOrDefaultAsync(p => p.Id == dto.PortfolioId);

            if (portfolio is null)
            {
                return new ErrorResponse(new NotFound
                {
                    Title = "Portfolio not found",
                    Message = $"The portfolio with portfolioId: {dto.PortfolioId} could not be found.",
                }, HttpStatusCode.NotFound);
            }
                
            if (!portfolio.User.HasPublicPortfolio && portfolio.User.Uid != uid)
            {
                return new ErrorResponse(new NotAuthorized
                {
                    Title = "Portfolio is private",
                    Message = "Tried to access other user's portfolio",
                }, HttpStatusCode.Unauthorized);
            }
                
            _logger.Information("User with user uid {@Uid} fetched portfolio with portfolio id {@PortfolioId} successfully", uid, dto.PortfolioId);

            return _mapper.Map<PortfolioResponseDto>(portfolio);
        }

        var portfolioByUserId = await query.FirstOrDefaultAsync(p => p.UserId == dto.UserId);

        if (portfolioByUserId is null)
        {
            return new ErrorResponse(new NotFound
            {
                Title = "Portfolio not found",
                Message = $"The portfolio with userId: {dto.UserId} could not be found.",
            }, HttpStatusCode.NotFound);
        }
            
        if (!portfolioByUserId.User.HasPublicPortfolio && portfolioByUserId.User.Uid != uid)
        {
            return new ErrorResponse(new NotAuthorized
            {
                Title = "Portfolio is private",
                Message = "Tried to access other user's portfolio",
            }, HttpStatusCode.Unauthorized);
        }
            
        _logger.Information("User with user uid {@Uid} fetched portfolio by user id {@UserId} successfully", uid, dto.UserId);

        return _mapper.Map<PortfolioResponseDto>(portfolioByUserId);
    }
}