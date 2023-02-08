namespace Domain.Common.Position;

public interface IPosition
{
    public int Id { get; set; }
    public string Isin { get; set; }
    public decimal BuyInPrice { get; set; }
    public decimal NumberOfShares { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}