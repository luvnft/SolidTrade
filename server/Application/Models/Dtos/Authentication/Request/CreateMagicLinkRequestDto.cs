using System.ComponentModel.DataAnnotations;

namespace Application.Models.Dtos.Authentication.Request;

public class CreateMagicLinkRequestDto
{
    [Required]
    [EmailAddress]
    public string Email { get; init; }
}