using Application.Models.Dtos.HistoricalPosition.Response;
using Application.Models.Dtos.Knockout.Response;
using Application.Models.Dtos.OngoingKnockout.Response;
using Application.Models.Dtos.OngoingWarrant.Response;
using Application.Models.Dtos.Portfolio.Response;
using Application.Models.Dtos.Position.Response;
using Application.Models.Dtos.ProductImage.Response;
using Application.Models.Dtos.StandingOrder.Response;
using Application.Models.Dtos.Stock.Response;
using Application.Models.Dtos.User.Response;
using Application.Models.Dtos.Warrant.Response;
using AutoMapper;
using Domain.Entities;
using Domain.Enums;

namespace Application.Models.MappingProfiles;

public class EntityToResponseDtoProfile : Profile
{
    public EntityToResponseDtoProfile()
    {
        CreateMap<User, UserResponseDto>();
        CreateMap<Portfolio, PortfolioResponseDto>()
            .ForMember(dest => dest.StockPositions,
                member => member.MapFrom(src => src.Positions.Where(p => p.Type == PositionType.Stock)))
            .ForMember(dest => dest.KnockOutPositions,
                member => member.MapFrom(src => src.Positions.Where(p => p.Type == PositionType.Knockout)))
            .ForMember(dest => dest.WarrantPositions,
                member => member.MapFrom(src => src.Positions.Where(p => p.Type == PositionType.Warrant)))
            .ForMember(dest => dest.OngoingKnockOutPositions,
                member => member.MapFrom(src => src.StandingOrders.Where(p => p.PositionType == PositionType.Knockout)))
            .ForMember(dest => dest.OngoingWarrantPositions,
                member => member.MapFrom(src => src.StandingOrders.Where(p => p.PositionType == PositionType.Warrant)));
        
        CreateMap<Position, PositionResponseDto>();
        
        CreateMap<Position, StockPositionResponseDto>();
        CreateMap<Position, KnockoutPositionResponseDto>();
        CreateMap<Position, WarrantPositionResponseDto>();
        CreateMap<Position, OngoingKnockoutPositionResponseDto>();
        CreateMap<Position, OngoingWarrantPositionResponseDto>();
        
        CreateMap<StandingOrder, StandingOrderResponseDto>();
        CreateMap<HistoricalPosition, HistoricalPositionResponseDto>();

        CreateMap<ProductImageRelation, GetProductImageResponseDto>()
            .ForMember(dest => dest.RedirectUrl,
                opt => opt.MapFrom(src => src.CorrespondingImageUrl));
    }
}