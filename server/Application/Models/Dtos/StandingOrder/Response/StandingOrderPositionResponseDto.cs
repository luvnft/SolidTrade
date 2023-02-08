using Application.Models.Dtos.Warrant.Response;
using Domain.Entities.Base;
using Domain.Enums;

namespace Application.Models.Dtos.StandingOrder.Response;

public class StandingOrderResponseDto : BaseEntity
{
    public DateTimeOffset GoodUntil { get; set; }
        
    public string Isin { get; set; }
        
    public OrderType Type { get; set; }
        
    public decimal Price { get; set; }
    public decimal NumberOfShares { get; set; }
}