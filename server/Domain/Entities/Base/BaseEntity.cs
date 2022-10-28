using System.ComponentModel.DataAnnotations;

namespace Domain.Entities.Base;

public abstract class BaseEntity
{
    [Key]
    public int Id { get; set; }
        
    [Timestamp]
    public byte[] TimeStamp { get; set; }
        
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}