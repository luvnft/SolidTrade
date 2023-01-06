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
        
    public ICollection<Position> Positions { get; set; }
    public ICollection<StandingOrder> StandingOrders { get; set; }
}