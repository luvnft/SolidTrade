using Application.Models.Dtos.Knockout.Response;
using Application.Models.Dtos.OngoingKnockout.Response;
using Application.Models.Dtos.OngoingWarrant.Response;
using Application.Models.Dtos.Stock.Response;
using Application.Models.Dtos.Warrant.Response;
using Domain.Entities.Base;

namespace Application.Models.Dtos.Portfolio.Response
{
    public class PortfolioResponseDto : BaseEntity
    {
        public int UserId { get; set; }
        
        public decimal Cash { get; set; }
        
        public decimal InitialCash { get; set; }
        
        public IReadOnlyCollection<StockPositionResponseDto> StockPositions { get; set; }
        public IReadOnlyCollection<WarrantPositionResponseDto> WarrantPositions { get; set; }
        public IReadOnlyCollection<KnockoutPositionResponseDto> KnockOutPositions { get; set; }
        public IReadOnlyCollection<OngoingWarrantPositionResponseDto> OngoingWarrantPositions { get; set; }
        public IReadOnlyCollection<OngoingKnockoutPositionResponseDto> OngoingKnockOutPositions { get; set; }
    }
}