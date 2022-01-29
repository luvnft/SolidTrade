import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/portfolio.dart';
import 'package:solidtrade/services/request/data_request_service.dart';

class PortfolioService {
  final BehaviorSubject<RequestResponse<Portfolio>?> _behaviorSubject = BehaviorSubject.seeded(null);
  ValueStream<RequestResponse<Portfolio>?> get stream$ => _behaviorSubject.stream;

  bool get currentHasValue => _behaviorSubject.hasValue;
  RequestResponse<Portfolio>? get current => _behaviorSubject.value;

  Future<RequestResponse<Portfolio>> fetchPortfolioByUserId({int? id}) async {
    var result = await DataRequestService.portfolioDataRequestService.getPortfolioByUserId(userId: id);

    _behaviorSubject.add(result);
    return result;
  }
}
