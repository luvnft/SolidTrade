import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/models/trade_republic/tr_request_response.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';
import 'package:solidtrade/services/util/debug/logger.dart';

abstract class ITransientService<T> extends IService<T?> {
  ITransientService(BehaviorSubject<T?> behaviorSubject) : super(behaviorSubject);

  final _logger = GetIt.instance.get<Logger>();
  bool _hadInitialListener = false;

  void onEvent(TrRequestResponse<T>? event, StreamSubscription<TrRequestResponse<T>?>? subscription) {
    if (event == null) {
      return;
    }

    if (!behaviorSubject.hasListener && _hadInitialListener) {
      subscription!.cancel();
      DataRequestService.trApiDataRequestService.unsub(event.id);
      behaviorSubject.close();
      return;
    }

    if (event.requestResponse.isSuccessful) {
      behaviorSubject.add(event.requestResponse.result);
    } else {
      _logger.f('If you see this error, then this issue has to be looked in to and future errors must be handled.');
      _logger.f('Received unsuccessful request response, which wont get handled. Error Message: ${event.requestResponse.error!.userFriendlyMessage}');
    }

    _hadInitialListener = true;
  }
}
