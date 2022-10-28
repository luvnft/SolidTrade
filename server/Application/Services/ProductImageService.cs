using System.Net;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Storage;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.Cache;
using Application.Errors;
using Application.Errors.Common;
using Application.Extensions;
using Application.Models.Dtos.ProductImage.Request;
using Application.Models.Dtos.ProductImage.Response;
using AutoMapper;
using Domain.Entities;
using Domain.Enums;
using Microsoft.EntityFrameworkCore;
using OneOf;
using Serilog;

namespace Application.Services;

public class ProductImageService : IProductImageService
{
    private readonly ILogger _logger = Log.ForContext<ProductImageService>();
    private readonly IMediaManagementService _mediaManagementService;
    private readonly ICacheService _cacheService;
    private readonly IApplicationDbContext _database;
    private readonly IMapper _mapper;

    public ProductImageService(IApplicationDbContext database, ICacheService cacheService, IMapper mapper, IMediaManagementService mediaManagementService)
    {
        _database = database;
        _cacheService = cacheService;
        _mapper = mapper;
        _mediaManagementService = mediaManagementService;
    }

    public async Task<OneOf<GetProductImageResponseDto, ErrorResponse>> GetOrCreateRedirectUrlToImage(GetProductImageRequestDto dto)
    {
        var identifier = dto.ThemeColor!.Value.CreateIdentifier(dto.Isin);
        var cachedValue = _cacheService.GetCachedValue<GetProductImageResponseDto>(identifier);

        if (!cachedValue.Expired)
            return CorrectGetProductImageResponseDto(cachedValue.Value, dto.IsWeb);
            
        var productImageRelation = await EntityFrameworkQueryableExtensions.FirstOrDefaultAsync(_database.ProductImageRelations, p =>
            p.Isin == dto.Isin && p.ThemeColor == dto.ThemeColor);

        if (productImageRelation is not null)
        {
            var responseDto = _mapper.Map<GetProductImageResponseDto>(productImageRelation);
                
            _cacheService.SetCachedValue(identifier, responseDto, int.MaxValue);
            return CorrectGetProductImageResponseDto(responseDto, dto.IsWeb);
        }

        var result = await CreateProductImage(dto.Isin);

        if (result.TryPickT1(out var error, out _))
        {
            return error;
        }

        var (lightThemeResponse, darkThemeResponse) = result.AsT0;
            
        _cacheService.SetCachedValue(
            lightThemeResponse.ThemeColor.CreateIdentifier(lightThemeResponse.Isin), 
            _mapper.Map<GetProductImageResponseDto>(lightThemeResponse), int.MaxValue);
        _cacheService.SetCachedValue(
            darkThemeResponse.ThemeColor.CreateIdentifier(darkThemeResponse.Isin), 
            _mapper.Map<GetProductImageResponseDto>(darkThemeResponse), int.MaxValue);

        try
        {
            _database.ProductImageRelations.Add(lightThemeResponse);
            _database.ProductImageRelations.Add(darkThemeResponse);
                
            _logger.Information("Trying to save new product image relation with isin {@Isin}", dto.Isin);
            await _database.SaveChangesAsync();
            _logger.Information("Save product image relation with isin {@Isin} was successful", dto.Isin);
                
            return CorrectGetProductImageResponseDto(
                _mapper.Map<GetProductImageResponseDto>(dto.ThemeColor == lightThemeResponse.ThemeColor
                    ? lightThemeResponse
                    : darkThemeResponse), dto.IsWeb);
        }
        catch (Exception e)
        {
            return new ErrorResponse(new UnexpectedError
            {
                Title = "Failed to add new product image relation",
                Message = "Failed to add new product image relation.",
                UserFriendlyMessage = "Something went wrong. Please try again later.",
                Exception = e,
                AdditionalData = new { dto },
            }, HttpStatusCode.InternalServerError);
        }
    }

    private async Task<OneOf<(ProductImageRelation, ProductImageRelation), ErrorResponse>> CreateProductImage(string isin)
    {
        var lightImage = _mediaManagementService.UploadTradeRepublicProductImage(isin, ProductImageThemeColor.Light);
        var darkImage = _mediaManagementService.UploadTradeRepublicProductImage(isin, ProductImageThemeColor.Dark);

        var results = await Task.WhenAll(lightImage, darkImage);

        if (results.Any(r => r.IsT1))
            return new ErrorResponse(results.First(r => r.IsT1).AsT1, HttpStatusCode.InternalServerError);

        var lightProductImageUri = (await lightImage).AsT0.AbsoluteUri;
        if (lightProductImageUri.EndsWith(".svg"))
        {
            lightProductImageUri = lightProductImageUri[..^3] + "png";
        }

        var darkProductImageUri = (await darkImage).AsT0.AbsoluteUri;
        if (darkProductImageUri.EndsWith(".svg"))
        {
            darkProductImageUri = darkProductImageUri[..^3] + "png";
        }
            
        var lightProductImage = new ProductImageRelation
        {
            Isin = isin,
            ThemeColor = ProductImageThemeColor.Light,
            CorrespondingImageUrl = lightProductImageUri,
        };
            
        var darkProductImage = new ProductImageRelation
        {
            Isin = isin,
            ThemeColor = ProductImageThemeColor.Dark,
            CorrespondingImageUrl = darkProductImageUri,
        };
            
        return (lightProductImage, darkProductImage);
    }

    private static GetProductImageResponseDto CorrectGetProductImageResponseDto(GetProductImageResponseDto dto,
        bool isWeb)
    {
        if (isWeb)
            return dto;
            
        dto.RedirectUrl = dto.RedirectUrl[..^3] + "svg";
        return dto;
    }
}