class NotFound implements _Failure {
  @override
  final String message;

  @override
  String? userFriendlyError;

  NotFound({required this.message, this.userFriendlyError});
}

abstract class _Failure {
  String? get userFriendlyError;
  String get message;
}
