using Domain.Entities.Base;

namespace Application.Models.Dtos.Warrant.Response;

public class WarrantPositionResponseDto : BaseEntity
{
    public string Isin { get; set; }
        
    public decimal BuyInPrice { get; set; }
    public decimal NumberOfShares { get; set; }
}