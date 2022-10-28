using System.ComponentModel.DataAnnotations;
using Domain.Common;
using Domain.Common.Position;
using Domain.Entities.Base;

namespace Domain.Entities;

public class KnockoutPosition : BaseEntity, IPosition
{
    [Required]
    public Portfolio Portfolio { get; set; }

    [Required]
    [MaxLength(12)]
    public string Isin { get; set; }
        
    [Required]
    [Range(DomainConstants.MinimumNumberOfShares, int.MaxValue)]
    public decimal NumberOfShares { get; set; }
        
    [Required]
    public decimal BuyInPrice { get; set; }
}