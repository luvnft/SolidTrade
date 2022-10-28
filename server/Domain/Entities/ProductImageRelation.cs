using System.ComponentModel.DataAnnotations;
using Domain.Entities.Base;
using Domain.Enums;

namespace Domain.Entities;

public class ProductImageRelation : BaseEntity
{
    [Required]
    [MaxLength(12)]
    public string Isin { get; set; }
        
    [Required]
    [MaxLength(512)]
    public string CorrespondingImageUrl { get; set; }
        
    [Required]
    public ProductImageThemeColor ThemeColor { get; set; }
}