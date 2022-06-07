import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:solidtrade/data/dtos/shared/request/buy_or_sell_position.dart';
import 'package:solidtrade/data/entities/knockout_position.dart';
import 'package:solidtrade/data/models/common/constants.dart';
import 'package:solidtrade/data/models/enums/shared_enums/buy_or_sell.dart';
import 'package:solidtrade/data/models/request_response/request_response.dart';
import 'package:solidtrade/services/request/base/base_request_service.dart';

class KnockoutDataRequestService extends IBaseRequestService {
  Future<RequestResponse<KnockoutPosition>> buyOrSellAtMarketPrice(BuyOrSell buyOrSell, BuyOrSellRequestDto dto) async {
    final body = JsonMapper.serialize(dto);
    var requestResponse = await makeRequest(buyOrSell == BuyOrSell.buy ? HttpMethod.post : HttpMethod.delete, Constants.endpointKnockout, body: body);
    return handleRequestResponse(requestResponse, (data) => KnockoutPosition.fromJson(data));
  }
}
