import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/common/shared/tr/tr_aggregate_history.dart';
import 'package:solidtrade/services/request/data_request_service.dart';

class AggregateHistoryService {
  final Map<String, TrAggregateHistory> _historys = {};

  Future<RequestResponse<TrAggregateHistory>> getTrAggregateHistory(String isinWithExtention, {String range = "1d"}) async {
    final key = "$isinWithExtention-$range";

    if (_historys.containsKey(key)) {
      return Future.value(RequestResponse.successful(_historys[key]!));
    }

    var requestString = Constants.getTrAggregateHistoryRequestString(isinWithExtention, range);
    var result = await DataRequestService.trApiDataRequestService.makeRequest<TrAggregateHistory>(requestString);

    if (result.isSuccessful) {
      _historys["$isinWithExtention-$range"] = result.result!;
    }

    return result;
  }
}
