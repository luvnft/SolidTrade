import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/user.dart';
import 'package:solidtrade/services/request/data_request_service.dart';

class UserService {
  final BehaviorSubject<RequestResponse<User>?> _behaviorSubject = BehaviorSubject.seeded(null);
  ValueStream<RequestResponse<User>?> get stream$ => _behaviorSubject.stream;

  bool get currentHasValue => _behaviorSubject.hasValue;
  RequestResponse<User>? get current => _behaviorSubject.value;

  Future<RequestResponse<User>> fetchUser() async {
    var result = await DataRequestService.userDataRequestService.fetchUser();

    _behaviorSubject.add(result);
    return result;
  }
}
