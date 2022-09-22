import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/models/common/constants.dart';
import 'package:solidtrade/pages/home/home_page.dart';
import 'package:solidtrade/pages/signup_and_signin/components/login_screen.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/user_util.dart';
import 'package:solidtrade/services/util/util.dart';

import 'package:url_launcher/url_launcher.dart';

class LoginSignIn extends StatelessWidget with STWidget {
  LoginSignIn({Key? key}) : super(key: key);

  final _historicalPositionService = GetIt.instance.get<HistoricalPositionService>();
  final _portfolioService = GetIt.instance.get<PortfolioService>();
  final _userService = GetIt.instance.get<UserService>();

  Future<void> _handleClickLoginWithGoogle(BuildContext context) async {
    var successful = await Util.requestNotificationPermissionsWithUserFriendlyPopup(context);

    if (!successful) {
      return;
    }

    var user = await UtilUserService.signInWithGoogle();

    if (user == null) {
      Util.googleLoginFailedDialog(context);
      return;
    }

    var closeDialog = Util.showLoadingDialog(context);

    var response = await _userService.fetchUser(user.uid);

    if (response.isSuccessful) {
      final userId = response.result!.id;
      await _historicalPositionService.fetchHistoricalPositions(userId);
      await _portfolioService.fetchPortfolioByUserId(userId);

      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      return;
    }

    closeDialog();
    Util.openDialog(context, "Login failed", message: response.error!.userFriendlyMessage);
  }

  void _handleClickForgotOrLostGoogleAccount() {
    launch(Constants.forgotOrLostAccountFormLink);
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      imageUrl: Constants.smokingGif,
      title: "Hello Again!",
      subTitle: "Welcome back you've been missed!",
      additionalWidgets: [
        Util.roundedButton(
          [
            Util.loadImage(Constants.googleLogoUrl, 20),
            const SizedBox(width: 10),
            const Text("Login with Google"),
          ],
          colors: colors,
          onPressed: () => _handleClickLoginWithGoogle(context),
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
