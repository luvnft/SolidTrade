import 'dart:convert';

import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/models/user.dart';
import 'package:solidtrade/services/request/base/base_request_service.dart';

class UserDataRequestService extends IBaseRequestService {
  Future<RequestResponse<User>> createUser(String displayName, String username, int initialBalance, String email, {String? profilePictureSeed}) async {
    var requestResponse = await makeRequest(
      HttpMethod.post,
      Constants.endpointUser,
      body: {
        "DisplayName": displayName,
        "Username": username,
        "Email": email,
        "InitialBalance": initialBalance,
        "ProfilePictureSeed": profilePictureSeed,
      },
    );

    if (!requestResponse.isSuccessful) {
      return RequestResponse.inheritErrorResponse(requestResponse);
    }

    var response = requestResponse.result!;
    var data = jsonDecode(response.body);
    return RequestResponse.successful(User.fromJson(data));
  }

  Future<RequestResponse<User>> fetchUserByUid(String uid) async {
    var requestResponse = await makeRequest(HttpMethod.get, Constants.endpointUser, queryParameters: {
      "Uid": uid,
    });

    if (!requestResponse.isSuccessful) {
      return RequestResponse.inheritErrorResponse(requestResponse);
    }

    var response = requestResponse.result!;
    var data = jsonDecode(response.body);
    return RequestResponse.successful(User.fromJson(data));
  }
}
