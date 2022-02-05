import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/data/common/shared/tr/tr_request_response.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';
import 'package:solidtrade/services/stream/tr_product_info_service.dart';

class TrProductPriceService extends BaseService<RequestResponse<TrProductPrice>?> {
  TrProductPriceService() : super(BehaviorSubject.seeded(null));

  void requestTrProductPrice(String isinWithExtention) async {
    StreamSubscription<TrRequestResponse<TrProductPrice>>? subscription;

    subscription = DataRequestService.trApiDataRequestService
        .makeRequestAsync<TrProductPrice>(
          Constants.getTrProductPriceRequestString(isinWithExtention),
        )
        .listen((event) => onEvent(event, subscription));
  }

  Future<RequestResponse<TrProductInfo>> requestTrProductPriceByIsinWithoutExtention(String isinWithoutExtention) async {
    var info = await GetIt.instance.get<TrProductInfoService>().requestTrProductInfo(isinWithoutExtention);

    if (!info.isSuccessful) {
      return info;
    }

    var isinWithExtention = "${info.result!.isin}.${info.result!.exchangeIds.first}";

    StreamSubscription<TrRequestResponse<TrProductPrice>>? subscription;

    subscription = DataRequestService.trApiDataRequestService
        .makeRequestAsync<TrProductPrice>(
          Constants.getTrProductPriceRequestString(isinWithExtention),
        )
        .listen((event) => onEvent(event, subscription));

    return info;
  }

  void onEvent(TrRequestResponse<TrProductPrice> event, StreamSubscription<TrRequestResponse<TrProductPrice>>? subscription) {
    if (behaviorSubject.hasListener) {
      behaviorSubject.add(event.requestResponse);
      return;
    }

    subscription!.cancel();
    DataRequestService.trApiDataRequestService.unsub(event.id);
    behaviorSubject.close();
  }
}
