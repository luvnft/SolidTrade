using Application.Models.Dtos.HistoricalPosition.Response;
using Application.Models.Dtos.Portfolio.Response;
using Domain.Entities.Base;

namespace Application.Models.Dtos.User.Response;

public class UserResponseDto : BaseEntity
{
    public PortfolioResponseDto Portfolio { get; set; }
    public IReadOnlyCollection<HistoricalPositionResponseDto> HistoricalPositions { get; set; }
        
    public string Username { get; set; }
                
    public string DisplayName { get; set; }
                
    public string ProfilePictureUrl { get; set; }
                
    public string Email { get; set; }
                
    public string Bio { get; set; }
        
    public string Uid { get; set; }
        
    public bool HasPublicPortfolio { get; set; }
}