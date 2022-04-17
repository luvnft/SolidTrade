import 'package:solidtrade/data/enums/environment.dart';
import 'package:solidtrade/app/main_common.dart';

Future<void> main() async {
  await commonMain(Environment.production);
}
