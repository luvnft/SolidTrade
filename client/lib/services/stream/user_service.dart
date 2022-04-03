import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/models/common/delete_user_response.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/user.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';

class UserService extends IService<RequestResponse<User>?> {
  UserService() : super(BehaviorSubject.seeded(null));

  Future<RequestResponse<User>> createUser(
    String displayName,
    String username,
    String email,
    int initialBalance, {
    String? profilePictureSeed,
    Uint8List? profilePictureFile,
  }) async {
    var result = await DataRequestService.userDataRequestService.createUser(
      displayName,
      username,
      initialBalance,
      email,
      profilePictureSeed: profilePictureSeed,
      profilePictureFile: profilePictureFile,
    );

    behaviorSubject.add(result);
    return result;
  }

  Future<RequestResponse<User>> fetchUser(String uid) async {
    var result = await DataRequestService.userDataRequestService.fetchUserByUid(uid);

    behaviorSubject.add(result);
    return result;
  }

  Future<RequestResponse<User>> fetchUserCurrentUser() async {
    var uid = fire.FirebaseAuth.instance.currentUser?.uid;

    RequestResponse<User> result;
    if (uid != null) {
      result = await DataRequestService.userDataRequestService.fetchUserByUid(uid);
    } else {
      result = RequestResponse.failedWithUserFriendlyMessage(Constants.notLoggedInMessage);
    }

    behaviorSubject.add(result);
    return result;
  }

  void updateUser(User user) {
    behaviorSubject.add(RequestResponse.successful(user));
  }

  Future<RequestResponse<Map<String, String>>> getUserAuthenticationHeader() async {
    final token = await getFirebaseUserAuthToken();

    if (token == null) {
      return RequestResponse.failedWithUserFriendlyMessage(Constants.notLoggedInMessage);
    }

    return RequestResponse.successful({
      "Authorization": "Bearer " + token.token!,
    });
  }

  Future<RequestResponse<DeleteUserResponse>> deleteUser() async {
    var response = await DataRequestService.userDataRequestService.deleteUser();

    if (response.isSuccessful) {
      behaviorSubject.add(RequestResponse.failed({
        "userFriendlyMessage": "User account has been deleted."
      }));

      return response;
    }

    return response;
  }

  Future<fire.IdTokenResult>? getFirebaseUserAuthToken() => fire.FirebaseAuth.instance.currentUser?.getIdTokenResult();
}
