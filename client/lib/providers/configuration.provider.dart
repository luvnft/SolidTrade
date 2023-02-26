import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solidtrade/data/types/failures/failures.dart';

part 'configuration.provider.g.dart';

enum _StorageKeys {
  userAuthToken,
  userAuthRefreshToken,
}

@riverpod
class Configuration extends _$Configuration {
  @override
  void build() {}

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Either<String, NotFound>> getToken() async {
    final token = await _storage.read(key: _StorageKeys.userAuthToken.toString());
    return token == null ? Right(NotFound(message: 'Token not found')) : Left(token);
  }

  Future<Either<String, NotFound>> getRefreshToken() async {
    final token = await _storage.read(key: _StorageKeys.userAuthRefreshToken.toString());
    return token == null ? Right(NotFound(message: 'Refresh token not found')) : Left(token);
  }
}
