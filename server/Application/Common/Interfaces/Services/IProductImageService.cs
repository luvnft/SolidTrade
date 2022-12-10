using Application.Errors.Types;
using Application.Models.Dtos.ProductImage.Request;
using Application.Models.Dtos.ProductImage.Response;
using Domain.Enums;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IProductImageService
{
    public Task<Result<GetProductImageResponseDto>> GetOrCreateRedirectUrlToImage(
        GetProductImageRequestDto dto);
}