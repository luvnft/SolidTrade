using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;
using SolidTradeServer.Data.Models.Annotations;
using static SolidTradeServer.Common.Shared;

namespace SolidTradeServer.Data.Dtos.User.Request
{
    public class UpdateUserDto
    {
        [EmailAddress]
        public string Email { get; init; }
        
        public string DisplayName { get; init; }
        
        public string Username { get; init; }
        
        public bool? PublicPortfolio { get; init; }
        
        public string Bio { get; init; }
        
        public string ProfilePictureSeed { get; init; }
        
        [MaxFileSize(MaxUploadFileSize)]
        public IFormFile ProfilePictureFile { get; init; }
    }
}