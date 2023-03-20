import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/data/models/request_response/error_response.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';

class RequestResponse<T> {
  final ErrorResponse? error;
  final T? result;
  final bool isSuccessful;

  String get _toJson => error != null ? '{"error": "${error!.userFriendlyMessage}"}' : JsonMapper.serialize(result!);

  const RequestResponse({
    required this.error,
    required this.result,
    required this.isSuccessful,
  });

  factory RequestResponse.successful(T value) {
    return RequestResponse(error: null, isSuccessful: true, result: value);
  }

  factory RequestResponse.failed(Map<String, dynamic> json) {
    return RequestResponse(error: ErrorResponse.fromJson(json), isSuccessful: false, result: null);
  }

  factory RequestResponse.inheritErrorResponse(RequestResponse response) {
    return RequestResponse(error: response.error, isSuccessful: false, result: null);
  }

  factory RequestResponse.failedWithUserFriendlyMessage(String message) {
    return RequestResponse(
      error: ErrorResponse.fromJson({
        'userFriendlyMessage': message
      }),
      isSuccessful: false,
      result: null,
    );
  }

  factory RequestResponse.failedUnexpectedly(Map<String, dynamic> data) {
    return RequestResponse(
      error: ErrorResponse.fromJson({
        'userFriendlyMessage': data['userFriendlyMessage'] ?? data['message'] ?? GetIt.instance.get<ConfigurationProvider>().languageProvider.language.common.httpFriendlyErrorResponse,
      }),
      isSuccessful: false,
      result: null,
    );
  }

  @override
  String toString() {
    try {
      return _toJson;
    } catch (_) {
      return super.toString();
    }
  }
}
