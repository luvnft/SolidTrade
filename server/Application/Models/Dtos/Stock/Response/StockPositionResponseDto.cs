using Domain.Entities.Base;

namespace Application.Models.Dtos.Stock.Response;

public class StockPositionResponseDto : BaseEntity
{
    public string Isin { get; set; }
        
    public decimal BuyInPrice { get; set; }
    public decimal NumberOfShares { get; set; }
}