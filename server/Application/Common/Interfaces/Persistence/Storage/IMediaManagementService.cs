using Application.Models.Types;
using Domain.Enums;
using Microsoft.AspNetCore.Http;

namespace Application.Common.Interfaces.Persistence.Storage;

public interface IMediaManagementService
{
    public Task<Result<Uri>> UploadTradeRepublicProductImage(string isin, ProductImageThemeColor themeColor);
    public Task<Result<Uri>> UploadProfilePicture(string url, string uid);
    public Task<Result<Uri>> UploadProfilePicture(IFormFile file, string uid);
    public Task<Result<OneOf.Types.Success>> DeleteImage(string url);
}