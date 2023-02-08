using Domain.Entities.Base;
using Domain.Enums;

namespace Application.Models.Dtos.HistoricalPosition.Response;

public class HistoricalPositionResponseDto : BaseEntity
{
    public PositionType PositionType { get; set; }
        
    public BuyOrSell BuyOrSell { get; set; }
        
    public decimal BuyInPrice { get; set; }
        
    public decimal Performance { get; set; }
        
    public decimal NumberOfShares { get; set; }
        
    public string Isin { get; set; }
}