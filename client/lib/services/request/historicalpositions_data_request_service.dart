import 'dart:convert';

import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/models/historicalposition.dart';
import 'package:http/http.dart' as http;

class HistoricalPositionsDataRequestService {
  Future<RequestResponse<List<HistoricalPosition>>> fetchHistoricalPosition(int userId) async {
    final url = ConfigReader.getBaseUrl() + Constants.endpointHistoricalPosition + userId.toString();

    // TODO: Remove uid in the future.
    final response = await http.get(Uri.parse(url), headers: {
      "Authorization": "Bearer 8AcxJgUEZvUWuN9JnfxNSwLahCb2"
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;

      var result = data.map((e) => HistoricalPosition.fromJson(e));
      return RequestResponse.successful(result.toList());
    } else if (response.statusCode == 400) {
      return RequestResponse.failedDueValidationError();
    } else {
      return RequestResponse.failed(jsonDecode(response.body));
    }
  }
}
