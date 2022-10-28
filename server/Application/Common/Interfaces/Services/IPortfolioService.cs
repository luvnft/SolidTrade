using Application.Errors.Common;
using Application.Models.Dtos.Portfolio.Request;
using Application.Models.Dtos.Portfolio.Response;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IPortfolioService
{
    public Task<OneOf<PortfolioResponseDto, ErrorResponse>> GetPortfolio(GetPortfolioRequestDto dto, string uid);
}