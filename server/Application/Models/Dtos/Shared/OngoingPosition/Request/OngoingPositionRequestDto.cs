using System.ComponentModel.DataAnnotations;
using Application.Common;
using Application.Models.Annotations;
using Domain.Common;
using Domain.Enums;

namespace Application.Models.Dtos.Shared.OngoingPosition.Request;

public class OngoingPositionRequestDto
{
    [Required] 
    public string Isin { get; set; }

    [Required]
    [Range(0.00010, int.MaxValue, ErrorMessage = ErrorMessages.PriceThresholdMessage)]
    public decimal PriceThreshold { get; set; }

    [Required]
    public EnterOrExitPositionType? Type { get; set; }
        
    [Required]
    [IsFutureDate(ErrorMessage = ErrorMessages.GoodUntilErrorMessage)]
    public DateTimeOffset? GoodUntil { get; set; }
        
    [Range(DomainConstants.MinimumNumberOfShares, int.MaxValue)]
    public decimal NumberOfShares { get; set; }
}