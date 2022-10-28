using System.ComponentModel.DataAnnotations;
using Application.Common;
using Application.Models.Annotations;
using Application.Models.Annotations.Group;
using Microsoft.AspNetCore.Http;

namespace Application.Models.Dtos.User.Request;

public class CreateUserRequestDto
{
    [Required]
    [MinLength(3)]
    public string DisplayName { get; init; }
        
    [Required]
    [EmailAddress]
    public string Email { get; init; }
        
    [Required]
    [UsernameValidator]
    public string Username { get; init; }
        
    [Required]
    [Range(1_000, 1_000_000)]
    public int InitialBalance { get; init; }
        
    [RequiredIf(nameof(ProfilePictureFile), null)]
    public string ProfilePictureSeed { get; init; }
        
    [MaxFileSize(ApplicationConstants.MaxUploadFileSize)]
    [RequiredIf(nameof(ProfilePictureSeed), null)]
    public IFormFile ProfilePictureFile { get; init; }
}