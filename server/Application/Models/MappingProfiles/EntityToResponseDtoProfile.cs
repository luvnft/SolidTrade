using Application.Models.Dtos.HistoricalPosition.Response;
using Application.Models.Dtos.Knockout.Response;
using Application.Models.Dtos.OngoingKnockout.Response;
using Application.Models.Dtos.OngoingWarrant.Response;
using Application.Models.Dtos.Portfolio.Response;
using Application.Models.Dtos.Position.Response;
using Application.Models.Dtos.ProductImage.Response;
using Application.Models.Dtos.Stock.Response;
using Application.Models.Dtos.User.Response;
using Application.Models.Dtos.Warrant.Response;
using AutoMapper;
using Domain.Entities;

namespace Application.Models.MappingProfiles;

public class EntityToResponseDtoProfile : Profile
{
    public EntityToResponseDtoProfile()
    {
        CreateMap<HistoricalPosition, HistoricalPositionResponseDto>();

        CreateMap<Position, PositionResponseDto>();
        CreateMap<KnockoutPosition, KnockoutPositionResponseDto>();
        CreateMap<WarrantPosition, WarrantPositionResponseDto>();
        CreateMap<StockPosition, StockPositionResponseDto>();
            
        CreateMap<OngoingKnockoutPosition, OngoingKnockoutPositionResponseDto>();
        CreateMap<OngoingWarrantPosition, OngoingWarrantPositionResponseDto>();
            
        CreateMap<Portfolio, PortfolioResponseDto>();
        CreateMap<User, UserResponseDto>();

        CreateMap<ProductImageRelation, GetProductImageResponseDto>()
            .ForMember(dest => dest.RedirectUrl,
                opt => opt.MapFrom(src => src.CorrespondingImageUrl));
    }
}