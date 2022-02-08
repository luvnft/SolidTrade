import 'dart:async';

import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/tr/tr_request_response.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';

abstract class ITransientService<T> extends IService<RequestResponse<T>?> {
  ITransientService(BehaviorSubject<RequestResponse<T>?> behaviorSubject) : super(behaviorSubject);

  bool hadInitialListener = false;

  void onEvent(TrRequestResponse<T>? event, StreamSubscription<TrRequestResponse<T>?>? subscription) {
    if (event == null) {
      return;
    }

    if (!behaviorSubject.hasListener && hadInitialListener) {
      subscription!.cancel();
      DataRequestService.trApiDataRequestService.unsub(event.id);
      behaviorSubject.close();
      return;
    }

    behaviorSubject.add(event.requestResponse);
    hadInitialListener = true;
  }
}
