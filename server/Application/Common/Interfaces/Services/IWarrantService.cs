using Application.Common.Interfaces.Persistence.Database;
using Application.Errors.Common;
using Application.Models.Dtos.Shared.Common;
using Application.Models.Dtos.Warrant.Response;
using Domain.Entities;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IWarrantService : IDisposable
{
    public Task<OneOf<WarrantPositionResponseDto, ErrorResponse>> GetWarrant(int id, string uid);

    public Task<OneOf<WarrantPositionResponseDto, ErrorResponse>> BuyWarrant(BuyOrSellRequestDto dto, string uid);

    public Task<OneOf<WarrantPositionResponseDto, ErrorResponse>> SellWarrant(BuyOrSellRequestDto dto, string uid);

    public Task<OneOf<WarrantPositionResponseDto, ErrorResponse>> SellWarrantInternal(IApplicationDbContext db,
        BuyOrSellRequestDto dto, User userWithPortfolio);
}