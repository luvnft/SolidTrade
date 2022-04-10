import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/common/shared/tr/tr_aggregate_history.dart';
import 'package:solidtrade/services/request/data_request_service.dart';

class AggregateHistoryService {
  final Map<String, TrAggregateHistory> _histories = {};

  Future<RequestResponse<TrAggregateHistory>> getTrAggregateHistory(String isinWithExtension, String range) async {
    final key = "$isinWithExtension-$range";

    if (_histories.containsKey(key)) {
      return Future.value(RequestResponse.successful(_histories[key]!));
    }

    var requestString = Constants.getTrAggregateHistoryRequestString(isinWithExtension, range);
    var result = await DataRequestService.trApiDataRequestService.makeRequest<TrAggregateHistory>(requestString);

    if (result.isSuccessful) {
      _histories["$isinWithExtension-$range"] = result.result!;
    }

    return result;
  }
}
