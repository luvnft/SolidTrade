using Application.Models.Annotations;

namespace Application.Models.Dtos.Portfolio.Request;

public class GetPortfolioRequestDto
{
    [RequiredIf(nameof(PortfolioId), null)]
    public int? UserId { get; init; }
        
    [RequiredIf(nameof(UserId), null)]
    public int? PortfolioId { get; init; }
}