using System.ComponentModel.DataAnnotations;
using static SolidTradeServer.Common.ErrorMessages;

namespace SolidTradeServer.Data.Dtos.Shared.Common
{
    public class BuyOrSellRequestDto
    {
        [Required]
        public string Isin { get; init; }
        
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = CountOfNumberOfSharedMessage)]
        public decimal NumberOfShares { get; init; }
    }
}