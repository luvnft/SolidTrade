import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/common/request/request_response.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/common/shared/tr/tr_stock_details.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';

class TrStockDetailsService extends IService<RequestResponse<TrStockDetails>?> {
  TrStockDetailsService() : super(BehaviorSubject.seeded(null));
  final Map<String, RequestResponse<TrStockDetails>> _cache = {};

  Future<RequestResponse<TrStockDetails>> requestTrProductInfo(String isinWithoutExtension) async {
    RequestResponse<TrStockDetails>? response;
    if (_cache.containsKey(isinWithoutExtension)) {
      response = _cache[isinWithoutExtension]!;
    } else {
      response = await DataRequestService.trApiDataRequestService.makeRequest<TrStockDetails>(Constants.getTrStockDetailsRequestString(isinWithoutExtension));
      _cache[isinWithoutExtension] = response;
    }

    behaviorSubject.add(response);
    return response;
  }
}
