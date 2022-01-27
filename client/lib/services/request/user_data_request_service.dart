import 'dart:convert';

import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/models/user.dart';

import 'package:http/http.dart' as http;

class UserDataRequestService {
  Future<RequestResponse<User>> fetchUser() async {
    final url = ConfigReader.getBaseUrl() + Constants.endpointUser;

    // TODO: Remove uid in the future.
    final response = await http.get(Uri.parse(url), headers: {
      "Authorization": "Bearer 8AcxJgUEZvUWuN9JnfxNSwLahCb2"
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      return RequestResponse.successful(User.fromJson(data));
    } else if (response.statusCode == 400) {
      return RequestResponse.failedDueValidationError();
    } else {
      return RequestResponse.failed(jsonDecode(response.body));
    }
  }
}
