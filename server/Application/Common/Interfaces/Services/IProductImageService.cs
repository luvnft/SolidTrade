using Application.Errors.Common;
using Application.Models.Dtos.ProductImage.Request;
using Application.Models.Dtos.ProductImage.Response;
using Domain.Enums;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IProductImageService
{
    public Task<OneOf<GetProductImageResponseDto, ErrorResponse>> GetOrCreateRedirectUrlToImage(
        GetProductImageRequestDto dto);
}