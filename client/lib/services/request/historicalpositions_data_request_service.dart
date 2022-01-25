import 'dart:convert';

import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/buy_or_sell.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/common/shared/position_type.dart';
import 'package:solidtrade/data/models/historicalposition.dart';
import 'package:http/http.dart' as http;

class HistoricalPositionsDataRequestService {
  Future<RequestResponse<List<HistoricalPosition>>> fetchHistoricalPosition(int userId) async {
    return RequestResponse.successful([
      HistoricalPosition(
        buyInPrice: 20.02,
        buyOrSell: BuyOrSell.buy,
        createdAt: DateTime.parse("2022-01-25T14:30:18.4468032+00:00"),
        id: 1,
        isin: "DE000TT3YXJ2",
        numberOfShares: 10,
        performance: -1,
        positionType: PositionType.knockout,
        updatedAt: DateTime.parse("2022-01-25T14:30:18.4468032+00:00"),
      ),
    ]);
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
