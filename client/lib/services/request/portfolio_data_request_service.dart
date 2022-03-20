import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/models/portfolio.dart';
import 'package:solidtrade/services/request/base/base_request_service.dart';
import 'dart:convert';

class PortfolioDataRequestService extends IBaseRequestService {
  Future<RequestResponse<Portfolio>> getPortfolioByUserId(int userId) async {
    final queryParameters = {
      'UserId': userId.toString(),
    };

    var requestResponse = await makeRequest(HttpMethod.get, Constants.endpointPortfolio, queryParameters: queryParameters);

    if (!requestResponse.isSuccessful) {
      return RequestResponse.inheritErrorResponse(requestResponse);
    }

    var response = requestResponse.result!;
    var data = jsonDecode(response.body);
    return RequestResponse.successful(Portfolio.fromJson(data));
  }
}
