import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/login/login_screen.dart';
import 'package:solidtrade/services/util/util.dart';

class LoginSignIn extends StatelessWidget with STWidget {
  LoginSignIn({Key? key}) : super(key: key);

  Future<void> _handleClickLoginWithGoogle() async {
    // TODO: ...
  }

  void _handleClickForgotOrLostGoogleAccount() {
    // TODO: Link to form where user recovery can be requested.
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      imageUrl: "https://c.tenor.com/wQ5IslyynbkAAAAC/elon-musk-smoke.gif",
      title: "Hello Again!",
      subTitle: "Welcome back you've been missed!",
      additionalWidgets: [
        Util.roundedButton(
          [
            Util.loadImage(
              "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1200px-Google_%22G%22_Logo.svg.png",
              20,
            ),
            const SizedBox(width: 10),
            const Text("Login with Google"),
          ],
          colors: colors,
          onPressed: _handleClickLoginWithGoogle,
        ),
        const SizedBox(height: 10),
        Util.roundedButton(
          [
            const Text("Forgot or lost your Google Account? Click here!"),
          ],
          colors: colors,
          onPressed: _handleClickForgotOrLostGoogleAccount,
        ),
      ],
    );
  }
}
