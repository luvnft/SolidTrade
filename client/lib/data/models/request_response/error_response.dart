import 'package:solidtrade/data/models/common/constants.dart';

class ErrorResponse {
  final String userFriendlyMessage;
  final bool isGenericErrorMessage;

  const ErrorResponse({
    required this.isGenericErrorMessage,
    required this.userFriendlyMessage,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      userFriendlyMessage: json['userFriendlyMessage'] ?? Constants.genericErrorMessage,
      isGenericErrorMessage: json['userFriendlyMessage'] == null,
    );
  }
}
