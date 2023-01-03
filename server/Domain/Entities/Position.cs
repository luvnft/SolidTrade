using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Domain.Common;
using Domain.Common.Position;
using Domain.Entities.Base;
using Domain.Enums;

namespace Domain.Entities;

public class Position : BaseEntity, IPosition
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

    [Required]
    [Column(TypeName = "nvarchar(8)")]
    public PositionType Type { get; set; }
}