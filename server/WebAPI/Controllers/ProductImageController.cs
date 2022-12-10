using Application.Common.Interfaces.Services;
using Application.Models.Dtos.ProductImage.Request;
using Microsoft.AspNetCore.Mvc;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/image")]
public class ProductImageController : Controller
{
    private readonly IProductImageService _productImageService;

    public ProductImageController(IProductImageService productImageService)
    {
        _productImageService = productImageService;
    }

    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] GetProductImageRequestDto dto)
    {
        var value = await _productImageService.GetOrCreateRedirectUrlToImage(dto);
        return value.Match<IActionResult>(response => RedirectPermanent(response.RedirectUrl), _ =>  MatchResult(value));
    }
}