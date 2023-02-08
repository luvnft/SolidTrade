using Domain.Entities.Base;

namespace Application.Models.Dtos.Knockout.Response;

public class KnockoutPositionResponseDto : BaseEntity
{
    public string Isin { get; set; }
        
    public decimal NumberOfShares { get; set; }
    public decimal BuyInPrice { get; set; }
}