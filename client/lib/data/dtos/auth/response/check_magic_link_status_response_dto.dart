import 'package:enum_to_string/enum_to_string.dart';

class CheckMagicLinkStatusResponseDto {
  final MagicLinkStatus status;
  final VerifyMagicLinkCodeResponseDto? tokens;

  CheckMagicLinkStatusResponseDto({
    required this.status,
    required this.tokens,
  });

  factory CheckMagicLinkStatusResponseDto.fromJson(Map<String, dynamic> json) {
    return CheckMagicLinkStatusResponseDto(
      status: EnumToString.fromString(MagicLinkStatus.values, json['status'])!,
      tokens: json['token'] == null ? null : VerifyMagicLinkCodeResponseDto.fromJson(json['token']),
    );
  }
}

class VerifyMagicLinkCodeResponseDto {
  final String token;
  final String refreshToken;

  VerifyMagicLinkCodeResponseDto({
    required this.token,
    required this.refreshToken,
  });

  factory VerifyMagicLinkCodeResponseDto.fromJson(Map<String, dynamic> json) {
    return VerifyMagicLinkCodeResponseDto(
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }
}

enum MagicLinkStatus {
  magicLinkClicked,
  magicLinkNotClicked,
}
