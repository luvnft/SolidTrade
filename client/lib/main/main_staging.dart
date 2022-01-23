import 'package:solidtrade/data/enums/environment.dart';
import 'package:solidtrade/main/main_common.dart';

Future<void> main() async {
  await commonMain(Environment.staging);
}
