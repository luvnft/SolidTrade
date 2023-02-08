using System.ComponentModel.DataAnnotations;
using Domain.Enums;

namespace Application.Models.Dtos.ProductImage.Request;

public class GetProductImageRequestDto
{
    [Required] 
    public string Isin { get; set; }

    [Required] 
    public ProductImageThemeColor? ThemeColor { get; set; }

    [Required]
    public bool IsWeb { get; set; }
}