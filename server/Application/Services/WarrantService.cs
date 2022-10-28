using System.Net;
using Application.Common.Interfaces.Persistence;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.TradeRepublic;
using Application.Errors;
using Application.Errors.Common;
using Application.Models.Dtos.Shared.Common;
using Application.Models.Dtos.TradeRepublic;
using Application.Models.Dtos.Warrant.Response;
using AutoMapper;
using Domain.Entities;
using Domain.Enums;
using Microsoft.EntityFrameworkCore;
using OneOf;
using Serilog;
using static Application.Common.Shared;

namespace Application.Services;

public class WarrantService : IWarrantService
{
    private readonly ILogger _logger = Log.ForContext<WarrantService>();
        
    private readonly ITradeRepublicApiService _trApiService;
    private readonly IApplicationDbContext _database;
    private readonly IMapper _mapper;

    public WarrantService(IApplicationDbContext database, IMapper mapper, ITradeRepublicApiService trApiService)
    {
        _trApiService = trApiService;
        _database = database;
        _mapper = mapper;
    }

    public async Task<OneOf<WarrantPositionResponseDto, ErrorResponse>> GetWarrant(int id, string uid)
    {
        var user = await _database.Users.AsQueryable()
            .FirstOrDefaultAsync(u => u.Portfolio.WarrantPositions.Any(w => w.Id == id));

        if (user is null)
        {
            return new ErrorResponse(new NotFound
            {
                Title = "User not found",
                Message = $"User with uid: {uid} could not be found",
            }, HttpStatusCode.NotFound);
        }
            
        if (!user.HasPublicPortfolio && uid != user.Uid)
        {
            return new ErrorResponse(new NotAuthorized
            {
                Title = "Portfolio is private",
                Message = "Tried to access other user's portfolio",
            }, HttpStatusCode.Unauthorized);
        }

        var warrant = await _database.WarrantPositions.FindAsync(id);

        if (warrant is null)
        {
            return new ErrorResponse(new NotFound
            {
                Title = "Warrant not found",
                Message = $"Warrant with id: {id} could not be found",
            }, HttpStatusCode.NotFound);
        }
            
        _logger.Information("User with user uid {@Uid} fetched warrant with warrant id {@WarrantId} successfully", uid, id);

        return _mapper.Map<WarrantPositionResponseDto>(warrant);
    }

    public async Task<OneOf<WarrantPositionResponseDto, ErrorResponse>> BuyWarrant(BuyOrSellRequestDto dto, string uid)
    {
        var result = await _trApiService.ValidateRequest(dto.Isin);

        if (result.TryPickT1(out var errorResponse, out _))
            return errorResponse;
            
        if ((await _trApiService.MakeTrRequest<TradeRepublicProductPriceResponseDto>(GetTradeRepublicProductPriceRequestString(dto.Isin))).TryPickT1(
                out errorResponse, out var trResponse))
            return errorResponse;

        var user = await _database.Users
            .Include(u => u.Portfolio)
            .FirstOrDefaultAsync(u => u.Uid == uid);
            
        var totalPrice = trResponse.Ask.Price * dto.NumberOfShares;

        if (totalPrice > user.Portfolio.Cash)
        {
            return new ErrorResponse(new InsufficientFounds
            {
                Title = "Insufficient funds",
                Message = "User founds not sufficient for purchase.",
                UserFriendlyMessage =
                    $"Balance insufficient. The total price is {totalPrice} but you have a balance of {user.Portfolio.Cash}",
                AdditionalData = new
                {
                    TotalPrice = totalPrice, UserBalance = user.Portfolio.Cash, Dto = dto,
                },
            }, HttpStatusCode.PaymentRequired);
        }
            
        var warrant = new WarrantPosition
        {
            Isin = ToIsinWithoutExchangeExtension(dto.Isin),
            BuyInPrice = trResponse.Ask.Price,
            Portfolio = user.Portfolio,
            NumberOfShares = dto.NumberOfShares,
        };
            
        var historicalPositions = new HistoricalPosition
        {
            BuyOrSell = BuyOrSell.Buy,
            Isin = warrant.Isin,
            Performance = -1,
            PositionType = PositionType.Warrant,
            UserId = user.Id,
            BuyInPrice = trResponse.Ask.Price,
            NumberOfShares = dto.NumberOfShares,
        };

        var (isNew, newWarrant) = await AddOrUpdate(warrant, user.Portfolio.Id);

        try
        {
            if (isNew)
                newWarrant = _database.WarrantPositions.Add(newWarrant).Entity;
            else
                newWarrant = _database.WarrantPositions.Update(newWarrant).Entity;

            user.Portfolio.Cash -= totalPrice;

            _database.Portfolios.Update(user.Portfolio);
            _database.HistoricalPositions.Add(historicalPositions);
                
            await _database.SaveChangesAsync();
            return _mapper.Map<WarrantPositionResponseDto>(newWarrant);
        }
        catch (Exception e)
        {
            return new ErrorResponse(new UnexpectedError
            {
                Title = "Could not buy position",
                Message = "Failed to buy position.",
                Exception = e,
                UserFriendlyMessage = "Something went very wrong. Please try again later.",
                AdditionalData = new { IsNew = isNew, Dto = dto, UserUid = uid, Message = "Maybe there was a problem with the isin?" },
            }, HttpStatusCode.InternalServerError);
        }
    }
        
    public async Task<OneOf<WarrantPositionResponseDto, ErrorResponse>> SellWarrant(BuyOrSellRequestDto dto, string uid)
    {
        var result = await _trApiService.ValidateRequest(dto.Isin);

        if (result.TryPickT1(out var errorResponse, out _))
            return errorResponse;
            
        var isinWithoutExchangeExtension = ToIsinWithoutExchangeExtension(dto.Isin);
            
        if ((await _trApiService.MakeTrRequest<TradeRepublicProductInfoDto>(GetTradeRepublicProductInfoRequestString(isinWithoutExchangeExtension))).TryPickT1(
                out errorResponse, out var isActiveResponse))
            return errorResponse;
            
        if (!isActiveResponse.Active!.Value)
        {
            const string message = "Product can not be bought or sold. This might happen if the product is expired or is knocked out.";
            return new ErrorResponse(new TradeFailed
            {
                Title = "Product can not be traded",
                Message = message,
                UserFriendlyMessage = message,
                AdditionalData = new { Dto = dto }
            }, HttpStatusCode.BadRequest);
        }
            
        var user = await _database.Users
            .Include(u => u.Portfolio)
            .FirstOrDefaultAsync(u => u.Uid == uid);
            
        return await SellWarrantInternal(_database, dto, user);
    }

    public async Task<OneOf<WarrantPositionResponseDto, ErrorResponse>> SellWarrantInternal(IApplicationDbContext db, BuyOrSellRequestDto dto, User userWithPortfolio)
    {
        var isinWithoutExchangeExtension = ToIsinWithoutExchangeExtension(dto.Isin);
            
        if ((await _trApiService.MakeTrRequest<TradeRepublicProductPriceResponseDto>(GetTradeRepublicProductPriceRequestString(dto.Isin))).TryPickT1(
                out var errorResponse3, out var trResponse))
            return errorResponse3;
            
        var totalGain = trResponse.Bid.Price * dto.NumberOfShares;
            
        var warrantPosition = await db.WarrantPositions.AsQueryable()
            .FirstOrDefaultAsync(w =>
                EF.Functions.Like(w.Isin, $"%{isinWithoutExchangeExtension}%") && userWithPortfolio.Portfolio.Id == w.Portfolio.Id);
            
        if (warrantPosition is null)
        {
            return new ErrorResponse(new NotFound
            {
                Title = "Warrant not found",
                Message = $"Warrant with isin: {isinWithoutExchangeExtension} could not be found.",
                AdditionalData = new {Dto = dto}
            }, HttpStatusCode.NotFound);
        }
            
        if (warrantPosition.NumberOfShares < dto.NumberOfShares)
        {
            return new ErrorResponse(new TradeFailed
            {
                Title = "Sell failed",
                Message = "Can't sell more shares than existent",
                UserFriendlyMessage = "You can't sell more shares than you have.",
                AdditionalData = new {Dto = dto, Warrant = _mapper.Map<WarrantPositionResponseDto>(warrantPosition)}
            }, HttpStatusCode.BadRequest);
        }
            
        var performance = trResponse.Bid.Price / warrantPosition.BuyInPrice;
            
        var historicalPositions = new HistoricalPosition
        {
            BuyOrSell = BuyOrSell.Sell,
            Isin = isinWithoutExchangeExtension,
            Performance = performance,
            PositionType = PositionType.Warrant,
            UserId = userWithPortfolio.Id,
            BuyInPrice = trResponse.Bid.Price,
            NumberOfShares = dto.NumberOfShares,
        };
            
        try
        {
            userWithPortfolio.Portfolio.Cash += totalGain;
            
            if (warrantPosition.NumberOfShares == dto.NumberOfShares)
                db.WarrantPositions.Remove(warrantPosition);
            else
            {
                warrantPosition.NumberOfShares -= dto.NumberOfShares;
                db.WarrantPositions.Update(warrantPosition);
            }
            
            // We save twice here because if we wouldn't the portfolio update would override the warrant position update or remove for some reason.
            // Saving here ensures that the portfolio update doesn't effect any warrants thanks to its timestamp.
            await db.SaveChangesAsync();
            
            db.Portfolios.Update(userWithPortfolio.Portfolio);
            db.HistoricalPositions.Add(historicalPositions);
            await db.SaveChangesAsync();
            return _mapper.Map<WarrantPositionResponseDto>(warrantPosition);
        }
        catch (Exception e)
        {
            return new ErrorResponse(new UnexpectedError
            {
                Title = "Could not sell position",
                Message = "Failed to sell position.",
                Exception = e,
                UserFriendlyMessage = "Something went very wrong. Please try again later.",
                AdditionalData = new
                {
                    SoldAll = warrantPosition.NumberOfShares == dto.NumberOfShares,
                    Dto = dto,
                    UserUid = userWithPortfolio.Uid,
                    Message = "Maybe there was a problem with the isin?"
                },
            }, HttpStatusCode.InternalServerError);
        }
    }

    private async Task<(bool, WarrantPosition)> AddOrUpdate(WarrantPosition warrantPosition, int portfolioId)
    {
        var warrant = await _database.WarrantPositions.AsQueryable()
            .FirstOrDefaultAsync(w =>
                EF.Functions.Like(w.Isin, $"%{warrantPosition.Isin}%") && portfolioId == w.Portfolio.Id);

        if (warrant is null)
            return (true, warrantPosition);

        var position = CalculateNewPosition(warrantPosition, warrant);

        warrant.BuyInPrice = position.BuyInPrice;
        warrant.NumberOfShares = position.NumberOfShares;
            
        return (false, warrant);
    }

    public void Dispose()
    {
        _database.Dispose();
    }
}