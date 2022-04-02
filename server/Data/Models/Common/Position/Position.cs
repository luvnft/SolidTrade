namespace SolidTradeServer.Data.Models.Common.Position
{
    public class Position : IPosition
    {
        public decimal BuyInPrice { get; set; }
        public decimal NumberOfShares { get; set; }
    }
}