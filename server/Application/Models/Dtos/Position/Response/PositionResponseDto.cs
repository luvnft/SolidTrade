using Domain.Entities.Base;

namespace Application.Models.Dtos.Position.Response;

public class PositionResponseDto : BaseEntity
{
    public string Isin { get; set; }
    public decimal BuyInPrice { get; set; }
    public decimal NumberOfShares { get; set; } 
}