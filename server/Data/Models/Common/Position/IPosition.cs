namespace SolidTradeServer.Data.Models.Common.Position
{
    public interface IPosition
    {
        public decimal BuyInPrice { get; set; }
        public decimal NumberOfShares { get; set; }
    }
}