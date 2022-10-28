using System.ComponentModel.DataAnnotations;
using Domain.Entities.Base;

namespace Domain.Entities;

public class Portfolio : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; }
        
    [Required]
    public decimal Cash { get; set; }
        
    [Required]
    public decimal InitialCash { get; set; }
        
    public ICollection<StockPosition> StockPositions { get; set; }
    public ICollection<WarrantPosition> WarrantPositions { get; set; }
    public ICollection<KnockoutPosition> KnockOutPositions { get; set; }
    public ICollection<OngoingWarrantPosition> OngoingWarrantPositions { get; set; }
    public ICollection<OngoingKnockoutPosition> OngoingKnockOutPositions { get; set; }
}