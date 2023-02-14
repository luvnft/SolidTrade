using System.ComponentModel.DataAnnotations;

namespace Application.Models.Dtos.Authentication.Request;

public class VerifyMagicLinkCodeRequestDto
{
    [Required]
    public Guid ConfirmationCode { get; init; }
}