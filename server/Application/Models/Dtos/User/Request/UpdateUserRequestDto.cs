using System.ComponentModel.DataAnnotations;
using Application.Common;
using Application.Models.Annotations;
using Application.Models.Annotations.Group;
using Microsoft.AspNetCore.Http;

namespace Application.Models.Dtos.User.Request;

public class UpdateUserDto
{
    [EmailAddress]
    public string Email { get; init; }
        
    [MinLength(3)]
    public string DisplayName { get; init; }
        
    [MinLength(3)]
    [UsernameValidator]
    public string Username { get; init; }
        
    public bool? PublicPortfolio { get; init; }
        
    public string Bio { get; init; }
        
    public string ProfilePictureSeed { get; init; }
        
    [MaxFileSize(ApplicationConstants.MaxUploadFileSize)]
    public IFormFile ProfilePictureFile { get; init; }
}