using Application.Errors.Types;
using Application.Models.Dtos.Portfolio.Request;
using Application.Models.Dtos.Portfolio.Response;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IPortfolioService
{
    public Task<Result<PortfolioResponseDto>> GetPortfolio(GetPortfolioRequestDto dto, string uid);
}