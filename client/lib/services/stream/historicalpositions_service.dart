import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/historicalposition.dart';
import 'package:rxdart/rxdart.dart';
import 'package:solidtrade/services/request/data_request_service.dart';

class HistoricalPositionService {
  final BehaviorSubject<RequestResponse<List<HistoricalPosition>>?> _behaviorSubject = BehaviorSubject.seeded(null);
  ValueStream<RequestResponse<List<HistoricalPosition>>?> get stream$ => _behaviorSubject.stream;

  bool get currentHasValue => _behaviorSubject.hasValue;
  RequestResponse<List<HistoricalPosition>>? get current => _behaviorSubject.value;

  Future<RequestResponse<List<HistoricalPosition>>> fetchHistoricalPositions(int userId) async {
    var future = DataRequestService.historicalPositionsDataRequestService.fetchHistoricalPosition(userId);

    var result = await future;
    _behaviorSubject.add(result);

    return future;
  }
}
