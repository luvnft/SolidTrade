using Application.Errors;
using Domain.Enums;
using Microsoft.AspNetCore.Http;
using OneOf;

namespace Application.Common.Interfaces.Persistence.Storage;

public interface IMediaManagementService
{
    public Task<OneOf<Uri, UnexpectedError>> UploadTradeRepublicProductImage(string isin, ProductImageThemeColor themeColor);
    public Task<OneOf<Uri, UnexpectedError>> UploadProfilePicture(string url, string uid);
    public Task<OneOf<Uri, UnexpectedError>> UploadProfilePicture(IFormFile file, string uid);
    public Task<OneOf<OneOf.Types.Success, UnexpectedError>> DeleteImage(string url);
}