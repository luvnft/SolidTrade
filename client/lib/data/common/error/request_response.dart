import 'package:get_it/get_it.dart';
import 'package:solidtrade/data/common/error/error_model.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';

class RequestResponse<T> {
  final ErrorModel? error;
  final T? result;
  final bool isSuccessful;

  const RequestResponse({
    required this.error,
    required this.result,
    required this.isSuccessful,
  });

  factory RequestResponse.successful(T value) {
    return RequestResponse(error: null, isSuccessful: true, result: value);
  }

  factory RequestResponse.failed(Map<String, dynamic> json) {
    return RequestResponse(error: ErrorModel.fromJson(json), isSuccessful: false, result: null);
  }

  factory RequestResponse.inheritErrorResponse(RequestResponse error) {
    return RequestResponse(error: error.error, isSuccessful: false, result: null);
  }

  factory RequestResponse.failedWithUserFriendlyMessage(String message) {
    return RequestResponse(
        error: ErrorModel.fromJson({
          "userFriendlyMessage": message
        }),
        isSuccessful: false,
        result: null);
  }

  factory RequestResponse.failedDueValidationError() {
    var provider = GetIt.instance.get<ConfigurationProvider>();

    return RequestResponse(
      error: ErrorModel.fromJson({
        "userFriendlyMessage": provider.languageProvider.language.common.httpFriendlyErrorResponse,
      }),
      isSuccessful: false,
      result: null,
    );
  }
}
