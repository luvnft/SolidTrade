import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:solidtrade/components/base/st_widget.dart';

class UtilLocalAuth {
  static final _logger = GetIt.instance.get<Logger>();
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    if (kIsWeb || !await _auth.isDeviceSupported()) {
      return true;
    }

    try {
      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      _logger.w("Error occurred when trying to authenticate user. See following Exception for more info");
      _logger.w(e);
      return false;
    }
  }
}
