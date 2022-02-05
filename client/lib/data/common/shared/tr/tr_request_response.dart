import 'package:solidtrade/data/common/error/request_response.dart';

class TrRequestResponse<T> {
  final int id;
  final RequestResponse<T> requestResponse;

  TrRequestResponse(this.id, this.requestResponse);
}
