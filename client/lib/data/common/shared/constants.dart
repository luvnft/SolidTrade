class Constants {
  static const endpointHistoricalPosition = "/historicalpositions/";
  static const endpointKnockout = "/knockouts/";
  static const endpointOngoingKnockout = "/knockouts/ongoing/";
  static const endpointOngoingWarrant = "/warrants/ongoing/";
  static const endpointPortfolio = "/portfolios/";
  static const endpointStock = "/stocks/";
  static const endpointUser = "/users/";
  static const endpointWarrant = "/warrants/";

  static const thousand = 1000;
  static const million = 1000000;
  static const billion = 1000000000;
  static const trillion = 1000000000000;

  static String getTrStockDetailsRequestString(String isin) => "{\"type\":\"stockDetails\",\"id\":\"$isin\"}";
  static String getTrProductInfoRequestString(String isin) => "{\"type\":\"instrument\",\"id\":\"$isin\"}";
  static String getTrProductPriceRequestString(String isin) => "{\"type\":\"ticker\",\"id\":\"$isin\"}";
  static String getTrAggregateHistoryRequestString(String isin, String range) => "{\"type\":\"aggregateHistoryLight\",\"range\":\"$range\",\"id\":\"$isin\"}";
}
