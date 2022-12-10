using Application.Common.Interfaces.Persistence.Database;
using Application.Errors.Types;
using Application.Models.Dtos.Shared.Common;
using Application.Models.Dtos.Warrant.Response;
using Domain.Entities;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IWarrantService : IDisposable
{
    public Task<Result<WarrantPositionResponseDto>> GetWarrant(int id, string uid);
    public Task<Result<WarrantPositionResponseDto>> BuyWarrant(BuyOrSellRequestDto dto, string uid);
    public Task<Result<WarrantPositionResponseDto>> SellWarrant(BuyOrSellRequestDto dto, string uid);
    public Task<Result<WarrantPositionResponseDto>> SellWarrantInternal(IApplicationDbContext db,
        BuyOrSellRequestDto dto, User userWithPortfolio);
}