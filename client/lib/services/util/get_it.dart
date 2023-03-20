import 'package:get_it/get_it.dart';

T get<T extends Object>({
  String? instanceName,
  dynamic param1,
  dynamic param2,
  GetIt? getItInstance,
}) {
  final getIt = getItInstance ?? GetIt.instance;
  return getIt.get<T>(
    instanceName: instanceName,
    param1: param1,
    param2: param2,
  );
}
