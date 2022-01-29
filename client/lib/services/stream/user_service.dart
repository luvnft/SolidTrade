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
    // TODO: Remove the uid in the future.
    var result = await DataRequestService.userDataRequestService.fetchUserByUid("8AcxJgUEZvUWuN9JnfxNSwLahCb2");

    _behaviorSubject.add(result);
    return result;
  }

  void updateUser(User user) {
    _behaviorSubject.add(RequestResponse.successful(user));
  }

  RequestResponse<Map<String, String>> getUserAuthenticationHeader() {
    // TODO: This can probably be removed.
    // if (current == null || !current!.isSuccessful) {
    //   return RequestResponse.failedWithUserfriendlyMessage("User session expired.\nPlease reopen the app.");
    // }

    // TODO: Use this user firebase token in the future.
    return RequestResponse.successful({
      "Authorization": "Bearer " + getFirebaseUserAuthToken(),
    });
  }

  String getFirebaseUserAuthToken() {
    // TODO: Remove this in the future.
    return "8AcxJgUEZvUWuN9JnfxNSwLahCb2";

    // TODO: Use this in the future.
    // https://firebase.flutter.dev/docs/auth/usage/
  }
}
