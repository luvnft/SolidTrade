import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/historicalposition.dart';
import 'package:rxdart/rxdart.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';

class HistoricalPositionService extends IService<RequestResponse<List<HistoricalPosition>>?> {
  HistoricalPositionService() : super(BehaviorSubject.seeded(null));

  Future<RequestResponse<List<HistoricalPosition>>> fetchHistoricalPositions(int userId) async {
    var future = DataRequestService.historicalPositionsDataRequestService.fetchHistoricalPosition(userId);

    var result = await future;
    behaviorSubject.add(result);

    return future;
  }
}
