import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/dtos/user/request/update_user_dto.dart';
import 'package:solidtrade/data/dtos/user/response/delete_user_response.dart';
import 'package:solidtrade/data/entities/user.dart';
import 'package:solidtrade/data/models/common/constants.dart';
import 'package:solidtrade/data/models/enums/client_enums/preferences_keys.dart';
import 'package:solidtrade/data/models/request_response/request_response.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';
import 'package:solidtrade/services/util/get_it.dart';

class UserService extends IService<User?> {
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

    if (result.isSuccessful) {
      behaviorSubject.add(result.result);
    }

    return result;
  }

  Future<RequestResponse<User>> updateUser(UpdateUserDto dto) async {
    var result = await DataRequestService.userDataRequestService.updateUser(dto, current!);

    if (result.isSuccessful) {
      behaviorSubject.add(result.result);
    }
    return result;
  }

  Future<RequestResponse<User>> fetchUser(String uid) async {
    var result = await DataRequestService.userDataRequestService.fetchUserByUid(uid);

    if (result.isSuccessful) {
      behaviorSubject.add(result.result);
    }
    return result;
  }

  Future<RequestResponse<User>> fetchUserCurrentUser() async {
    final result = await DataRequestService.userDataRequestService.fetchCurrentUser();

    if (result.isSuccessful) {
      behaviorSubject.add(result.result);
    }
    return result;
  }

  Future<RequestResponse<Map<String, String>>> getUserAuthenticationHeader() async {
    final token = await getUserToken();

    if (token == null) {
      return RequestResponse.failedWithUserFriendlyMessage(Constants.notLoggedInMessage);
    }

    return RequestResponse.successful({
      'Authorization': 'Bearer $token',
    });
  }

  Future<RequestResponse<Map<String, String>>> getUserDeviceHeader() async {
    // TODO: Do we still need this?
    var token = '';
    // final token = await getUserMessagingDeviceToken();

    if (token == null) {
      return RequestResponse.failedWithUserFriendlyMessage('Failed to request device token.\nPlease reopen the app. If this issue persists please reach out.');
    }

    return RequestResponse.successful({
      'DeviceToken': token,
    });
  }

  Future<RequestResponse<DeleteUserResponse>> deleteUser() async {
    var response = await DataRequestService.userDataRequestService.deleteUser();

    if (response.isSuccessful) {
      behaviorSubject.add(current!);

      return response;
    }

    return response;
  }

  Future<String?> getUserToken() async => get<FlutterSecureStorage>().read(key: SecureStorageKeys.token.name);
}
