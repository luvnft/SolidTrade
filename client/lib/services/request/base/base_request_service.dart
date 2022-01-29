import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/debug/log.dart';

abstract class IBaseRequestService {
  final UserService userService = GetIt.instance.get<UserService>();

  Future<RequestResponse<http.Response>> makeRequest(
    HttpMethod method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool selfHandleErrorCode = true,
  }) async {
    final uri = Uri.https(ConfigReader.getBaseUrl(), endpoint, queryParameters);

    Log.d(uri);

    var auth = userService.getUserAuthenticationHeader();

    if (!auth.isSuccessful && auth.result == null) {
      return RequestResponse.inheritErrorResponse(auth);
    }

    http.Response response;
    Map<String, String> headers = {
      ...?auth.result
    };

    switch (method) {
      case HttpMethod.get:
        response = await http.get(uri, headers: headers);
        break;
      case HttpMethod.post:
        response = await http.post(uri, headers: headers, body: body);
        break;
      case HttpMethod.patch:
        response = await http.patch(uri, headers: headers, body: body);
        break;
      case HttpMethod.delete:
        response = await http.delete(uri, headers: headers, body: body);
        break;
    }

    if (selfHandleErrorCode && response.statusCode != 200) {
      if (response.statusCode == 400) {
        return RequestResponse.failedDueValidationError();
      } else {
        return RequestResponse.failed(jsonDecode(response.body));
      }
    }

    return RequestResponse.successful(response);
  }
}

enum HttpMethod {
  get,
  post,
  patch,
  delete,
}
