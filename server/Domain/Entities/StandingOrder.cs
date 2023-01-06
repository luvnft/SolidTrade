using System.ComponentModel.DataAnnotations;
using Domain.Common;
using Domain.Entities.Base;
using Domain.Enums;

namespace Domain.Entities;

public class StandingOrder : BaseEntity
{
    [Required]
    public Portfolio Portfolio { get; set; }
        
    [Required]
    [MaxLength(12)]
    public string Isin { get; set; }
        
    [Required]
    [Range(0.00010, int.MaxValue)]
    public decimal Price { get; set; }
        
    [Required]
    [Range(DomainConstants.MinimumNumberOfShares, int.MaxValue)]
    public decimal NumberOfShares  { get; set; }
    
    [Required] 
    public DateTimeOffset GoodUntil { get; set; }
    
    [Required]
    public OrderType OrderType { get; set; }
    
    [Required]
    public PositionType PositionType { get; set; }
}