using Application.Models.Dtos.StandingOrder.Request;
using Application.Models.Dtos.StandingOrder.Response;

namespace Application.Common.Interfaces.Services;

public interface IStandingOrderService
{
    public Task<Result<StandingOrderResponseDto>> GetStandingOrder(int id, string uid);
    public Task<Result<StandingOrderResponseDto>> CreateStandingOrder(CreateStandingOrderRequestDto dto, string uid);
    public Task<Result<StandingOrderResponseDto>> CloseStandingOrder(CloseStandingOrderRequestDto dto, string uid); 
}