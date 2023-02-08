using System.ComponentModel.DataAnnotations;
using Application.Common;
using Domain.Common;

namespace Application.Models.Dtos.Shared.Common;

public class BuyOrSellRequestDto
{
    [Required]
    public string Isin { get; init; }
        
    [Required]
    [Range(DomainConstants.MinimumNumberOfShares, int.MaxValue, ErrorMessage = ErrorMessages.CountOfNumberOfSharedMessage)]
    public decimal NumberOfShares { get; init; }
}