import 'package:solidtrade/data/models/enums/client_enums/derivatives_query_options.dart';
import 'package:solidtrade/data/models/enums/shared_enums/position_type.dart';

class Constants {
  static const smokingGif = 'https://c.tenor.com/wQ5IslyynbkAAAAC/elon-musk-smoke.gif';
  static const googleLogoUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1200px-Google_%22G%22_Logo.svg.png';

  // TODO: The docs need an update.
  static const forgotOrLostAccountFormLink = 'https://docs.google.com/forms/d/181J0K5WYEPrI0h4_flZBNtz3Io5VSEo07c9SflOUtGY/';
  static const learnMoreAboutOrderTypesLink = 'https://www.investopedia.com/investing/basics-trading-stock-know-your-orders/';
  static const fileUploadLimitInBytes = 10000000; // 10MB

  static const endpointHistoricalPosition = '/historicalpositions/';
  static const endpointKnockout = '/knockouts/';
  static const endpointOngoingKnockout = '/knockouts/ongoing/';
  static const endpointOngoingWarrant = '/warrants/ongoing/';
  static const endpointPortfolio = '/portfolios/';
  static const endpointStock = '/stocks/';
  static const endpointUser = '/users/';
  static const endpointAuth = '/auth/';
  static const endpointWarrant = '/warrants/';

  static const genericErrorMessage = 'Something went wrong. Please try again later.';
  static const notLoggedInMessage = 'User session expired.\nPlease login.';

  static const thousand = 1000;
  static const million = 1000000;
  static const billion = 1000000000;
  static const trillion = 1000000000000;

  static String getTrProductSearchRequestString(String search, String searchType) => '{"type":"neonSearch","data":{"q":"$search","page":1,"pageSize":10,"filter":[{"key":"type","value":"$searchType"}]}}';
  static String getTrStockDetailsRequestString(String isin) => '{"type":"stockDetails","id":"$isin"}';
  static String getTrProductInfoRequestString(String isin) => '{"type":"instrument","id":"$isin"}';
  static String getTrProductPriceRequestString(String isin) => '{"type":"ticker","id":"$isin"}';
  static String getTrAggregateHistoryRequestString(String isin, String range) => '{"type":"aggregateHistoryLight","range":"$range","id":"$isin"}';
  static String getTrDerivativesRequestString({
    required String isin,
    required PositionType derivativeType,
    required DerivativesSortOptions sortBy,
    required DerivativesOptionType filterByType,
    required int numberOfAvailableProducts,
    DerivativesSortDirectionOptions sortDirection = DerivativesSortDirectionOptions.asc,
  }) =>
      '{"type":"derivatives","lang":"en","underlying":"$isin","productCategory":"${derivativeType.trName}","leverage":0,"sortBy":"${sortBy.name}","sortDirection":"${sortDirection.name}","optionType":"${filterByType.name}","pageSize":$numberOfAvailableProducts,"after":"0"}';
}
