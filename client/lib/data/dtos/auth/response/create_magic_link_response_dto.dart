class CreateMagicLinkResponseDto {
  final String confirmationStatusCode;

  const CreateMagicLinkResponseDto({required this.confirmationStatusCode});

  factory CreateMagicLinkResponseDto.fromJson(Map<String, dynamic> json) {
    return CreateMagicLinkResponseDto(
      confirmationStatusCode: json['confirmationStatusCode'],
    );
  }
}
