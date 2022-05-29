import 'dart:convert';

import 'package:solidtrade/data/entities/historicalposition.dart';
import 'package:solidtrade/data/models/common/constants.dart';
import 'package:solidtrade/data/models/request_response/request_response.dart';
import 'package:solidtrade/services/request/base/base_request_service.dart';

class HistoricalPositionsDataRequestService extends IBaseRequestService {
  Future<RequestResponse<List<HistoricalPosition>>> fetchHistoricalPosition(int userId) async {
    var requestResponse = await makeRequest(HttpMethod.get, Constants.endpointHistoricalPosition + userId.toString());

    if (!requestResponse.isSuccessful) {
      return RequestResponse.inheritErrorResponse(requestResponse);
    }

    var response = requestResponse.result!;
    var data = jsonDecode(response.body) as List<dynamic>;
    var result = data.map((e) => HistoricalPosition.fromJson(e));
    return RequestResponse.successful(result.toList());
  }
}
