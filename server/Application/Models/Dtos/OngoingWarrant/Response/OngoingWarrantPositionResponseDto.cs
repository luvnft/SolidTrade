using Application.Models.Dtos.Warrant.Response;
using Domain.Entities.Base;
using Domain.Enums;

namespace Application.Models.Dtos.OngoingWarrant.Response;

public class OngoingWarrantPositionResponseDto : BaseEntity
{
    public DateTimeOffset GoodUntil { get; set; }
        
    public string Isin { get; set; }
        
    public OrderType Type { get; set; }
        
    public WarrantPositionResponseDto CurrentWarrantPosition { get; set; }
    public decimal Price { get; set; }
    public decimal NumberOfShares { get; set; }
}