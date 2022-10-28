using System.ComponentModel.DataAnnotations;
using Domain.Common;
using Domain.Common.Position;
using Domain.Entities.Base;
using Domain.Enums;

namespace Domain.Entities;

public class HistoricalPosition : BaseEntity, IPosition
{
    public int UserId { get; set; }
        
    [Required]
    public PositionType PositionType { get; set; }
        
    [Required]
    public BuyOrSell BuyOrSell { get; set; }
        
    [Required]
    public decimal BuyInPrice { get; set; }
        
    [Required]
    public decimal Performance { get; set; }
        
    [Required]
    [Range(DomainConstants.MinimumNumberOfShares, int.MaxValue)]
    public decimal NumberOfShares { get; set; }
        
    [Required]
    [MaxLength(12)]
    public string Isin { get; set; }
}