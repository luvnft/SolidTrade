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

namespace Application.Models.MappingProfiles;

public class EntityToResponseDtoProfile : Profile
{
    public EntityToResponseDtoProfile()
    {
        CreateMap<User, UserResponseDto>();
        CreateMap<Portfolio, PortfolioResponseDto>();
        CreateMap<Position, PositionResponseDto>();
        CreateMap<StandingOrder, StandingOrderResponseDto>();
        CreateMap<HistoricalPosition, HistoricalPositionResponseDto>();

        CreateMap<ProductImageRelation, GetProductImageResponseDto>()
            .ForMember(dest => dest.RedirectUrl,
                opt => opt.MapFrom(src => src.CorrespondingImageUrl));
    }
}