using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Models.Dtos.Portfolio.Request;
using Application.Models.Dtos.Portfolio.Response;
using AutoMapper;
using Serilog;

namespace Application.Services;

public class PortfolioService : IPortfolioService
{
    private readonly ILogger _logger = Log.ForContext<PortfolioService>();
        
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public PortfolioService(IUnitOfWork unitOfWork, IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }

    public async Task<Result<PortfolioResponseDto>> GetPortfolio(GetPortfolioRequestDto dto, string uid)
    {
        if (dto.PortfolioId.HasValue)
        {
            var portfolioResult = await _unitOfWork.Portfolios.GetPortfolioByIdAndIncludeAll(dto.PortfolioId.Value);

            if (portfolioResult.TryTakeError(out var error, out var portfolio))
                return error;
            
            if (!portfolio.User.HasPublicPortfolio && portfolio.User.Uid != uid)
                return NotAuthorized.PrivatePortfolio();

            _logger.Information("User with user uid {@Uid} fetched portfolio with portfolio id {@PortfolioId} successfully", uid, dto.PortfolioId);

            return _mapper.Map<PortfolioResponseDto>(portfolio);
        }
        else
        {
            var portfolioResult = await _unitOfWork.Portfolios.GetPortfolioByUserIdAndIncludeAll(dto.UserId!.Value);
            if (portfolioResult.TryTakeError(out var error, out var portfolio))
                return error;
                
            if (!portfolio.User.HasPublicPortfolio && portfolio.User.Uid != uid)
                return NotAuthorized.PrivatePortfolio();
                
            _logger.Information("User with user uid {@Uid} fetched portfolio by user id {@UserId} successfully", uid, dto.UserId);

            return _mapper.Map<PortfolioResponseDto>(portfolio);
        }
    }
}