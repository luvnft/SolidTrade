import 'package:solidtrade/data/models/common/request_response_models/request_response.dart';

class TrRequestResponse<T> {
  final int id;
  final RequestResponse<T> requestResponse;

  TrRequestResponse(this.id, this.requestResponse);
}
