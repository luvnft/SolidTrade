namespace Application.Extensions;

public static class StringTradeRepublicExtensions
{
    public static TradeRepublicStringConverter ToTradeRepublic(this string value) => new(value);
}

public class TradeRepublicStringConverter
{
    public TradeRepublicStringConverter(string value)
    {
        _value = value;
    }

    private readonly string _value;
    
    public string ProductInfo()
        => "{\"type\":\"instrument\",\"id\":\"" + _value + "\"}";
    
    public string GetTradeRepublicProductPriceRequestString()
        => "{\"type\":\"ticker\",\"id\":\"" + _value + "\"}";
    
    public string IsinWithoutExchangeExtension()
    {
        var i = _value.IndexOf('.');
        return i == -1 ? _value.Trim().ToUpper() : _value[..i].Trim().ToUpper();
    }
}