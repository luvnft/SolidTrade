import 'package:solidtrade/app/main_common.dart';
import 'package:solidtrade/app/main_prod.mapper.g.dart';
import 'package:solidtrade/data/models/enums/client_enums/environment.dart';

Future<void> main() async {
  initializeJsonMapper();
  await commonMain(Environment.production);
}
