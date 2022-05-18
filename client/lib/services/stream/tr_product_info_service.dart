import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/common/request/request_response.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';

class TrProductInfoService extends IService<TrProductInfo?> {
  TrProductInfoService() : super(BehaviorSubject.seeded(null));

  Future<RequestResponse<TrProductInfo>> requestTrProductInfo(String isinWithoutExtension) async {
    var result = await DataRequestService.trApiDataRequestService.makeRequest<TrProductInfo>(Constants.getTrProductInfoRequestString(isinWithoutExtension));
    if (result.isSuccessful) {
      behaviorSubject.add(result.result);
    }

    return result;
  }
}
