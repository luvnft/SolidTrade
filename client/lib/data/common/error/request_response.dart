import 'package:solidtrade/data/common/error/error_model.dart';

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

  factory RequestResponse.failedDueValidationError() {
    return RequestResponse(
      error: ErrorModel.fromJson({
        "userFriendlyMessage": "Something went wrong. Please make sure your input is valid."
      }),
      isSuccessful: false,
      result: null,
    );
  }
}
