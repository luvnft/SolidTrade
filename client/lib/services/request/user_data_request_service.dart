import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:solidtrade/data/models/common/delete_user_response.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/models/user.dart';
import 'package:solidtrade/services/request/base/base_request_service.dart';

class UserDataRequestService extends IBaseRequestService {
  Future<RequestResponse<User>> createUser(
    String displayName,
    String username,
    int initialBalance,
    String email, {
    String? profilePictureSeed,
    Uint8List? profilePictureFile,
  }) async {
    Map<String, String> body = {
      "DisplayName": displayName,
      "Username": username,
      "Email": email,
      "ProfilePictureSeed": profilePictureSeed.toString(),
      "InitialBalance": initialBalance.toString(),
    };

    Map<String, List<int>> files = profilePictureFile != null
        ? {
            "ProfilePictureFile": profilePictureFile
          }
        : {};

    var requestResponse = await makeRequestWithMultipartFile(
      HttpMethod.post,
      Constants.endpointUser,
      fields: body,
      files: files,
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

  Future<RequestResponse<DeleteUserResponse>> deleteUser() async {
    var requestResponse = await makeRequest(
      HttpMethod.delete,
      Constants.endpointUser,
    );

    if (!requestResponse.isSuccessful) {
      return RequestResponse.inheritErrorResponse(requestResponse);
    }

    var response = requestResponse.result!;
    var data = jsonDecode(response.body);
    return RequestResponse.successful(DeleteUserResponse.fromJson(data));
  }
}
