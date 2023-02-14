using System.ComponentModel.DataAnnotations;
using Application.Models.Dtos.Authentication.Response;

namespace Application.Models.Dtos.Authentication.Request;

/// <see cref="CreateMagicLinkResponseDto"/> is used to create a magic link for a user.
public class CheckMagicLinkStatusRequestDto
{
    [Required]
    public Guid ConfirmationStatusCode { get; init; }
}