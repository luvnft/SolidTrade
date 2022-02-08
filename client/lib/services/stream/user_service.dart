import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/user.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';

class UserService extends IService<RequestResponse<User>?> {
  UserService() : super(BehaviorSubject.seeded(null));

  Future<RequestResponse<User>> fetchUser() async {
    // TODO: Remove the uid in the future.
    var result = await DataRequestService.userDataRequestService.fetchUserByUid("8AcxJgUEZvUWuN9JnfxNSwLahCb2");

    behaviorSubject.add(result);
    return result;
  }

  void updateUser(User user) {
    behaviorSubject.add(RequestResponse.successful(user));
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
