using Domain.Entities.Base;
using Domain.Enums;

namespace Application.Models.Dtos.OngoingKnockout.Response;

public class OngoingKnockoutPositionResponseDto : BaseEntity
{
    public DateTimeOffset GoodUntil { get; set; }
        
    public string Isin { get; set; }
        
    public EnterOrExitPositionType Type { get; set; }
        
    public OngoingKnockoutPositionResponseDto CurrentKnockoutPosition { get; set; }
    public decimal Price { get; set; }
    public decimal NumberOfShares { get; set; }
}