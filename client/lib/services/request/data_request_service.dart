import 'package:solidtrade/services/request/historicalpositions_data_request_service.dart';
import 'package:solidtrade/services/request/knockout_data_request_service.dart';
import 'package:solidtrade/services/request/ongoing_knockout_data_request_service.dart';
import 'package:solidtrade/services/request/ongoing_warrant_data_request_service.dart';
import 'package:solidtrade/services/request/portfolio_data_request_service.dart';
import 'package:solidtrade/services/request/stock_data_request_service.dart';
import 'package:solidtrade/services/request/tr_api_data_request_service.dart';
import 'package:solidtrade/services/request/user_data_request_service.dart';
import 'package:solidtrade/services/request/warrant_data_request_service.dart';

class DataRequestService {
  static HistoricalPositionsDataRequestService historicalPositionsDataRequestService = HistoricalPositionsDataRequestService();
  static KnockoutDataRequestService knockoutDataRequestService = KnockoutDataRequestService();
  static OngoingKnockoutDataRequestService ongoingKnockoutDataRequestService = OngoingKnockoutDataRequestService();
  static OngoingWarrantDataRequestService ongoingWarrantDataRequestService = OngoingWarrantDataRequestService();
  static PortfolioDataRequestService portfolioDataRequestService = PortfolioDataRequestService();
  static StockDataRequestService stockDataRequestService = StockDataRequestService();
  static UserDataRequestService userDataRequestService = UserDataRequestService();
  static WarrantDataRequestService warrantDataRequestService = WarrantDataRequestService();
  static TrApiDataRequestService trApiDataRequestService = TrApiDataRequestService();
}
