class Constants {
  static const endpointHistoricalPosition = "/historicalpositions/";
  static const endpointKnockout = "/knockouts/";
  static const endpointOngoingKnockout = "/knockouts/ongoing/";
  static const endpointOngoingWarrant = "/warrants/ongoing/";
  static const endpointPortfolio = "/portfolios/";
  static const endpointStock = "/stocks/";
  static const endpointUser = "/users/";
  static const endpointWarrant = "/warrants/";

  static String getTrProductInfoRequestString(String isin) => "{\"type\":\"instrument\",\"id\":\"$isin\"}";
  static String getTrProductPriceRequestString(String isin) => "{\"type\":\"ticker\",\"id\":\"$isin\"}";
}
