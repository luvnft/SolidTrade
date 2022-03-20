import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/login/login_screen.dart';
import 'package:solidtrade/services/util/user_util.dart';
import 'package:solidtrade/services/util/util.dart';

class LoginHome extends StatelessWidget with STWidget {
  LoginHome({Key? key, required this.tabController}) : super(key: key);

  final TabController tabController;

  Future<void> _handleClickCreateAccount() async {
    var user = await UtilUserService.signInWithGoogle();

    if (user != null) {
      tabController.animateTo(0);
    }
  }

  void _handleClickLoginUser() => tabController.animateTo(2);

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      imageUrl: "https://c.tenor.com/wQ5IslyynbkAAAAC/elon-musk-smoke.gif",
      // title: "Too broke to start investing? Fear not.",
      title: "Too broke to start investing?\n",
      subTitle: "Start paper trading with Stocks, ETFs and Derivatives. Try new investment strategies and compare your portfilio with friends and others!",
      additionalWidgets: [
        Util.roundedButton(
          [
            Util.loadImage(
              "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1200px-Google_%22G%22_Logo.svg.png",
              20,
            ),
            const SizedBox(width: 10),
            const Text("Create new account with Google"),
          ],
          colors: colors,
          onPressed: _handleClickCreateAccount,
        ),
        const SizedBox(height: 10),
        Util.roundedButton([
          const Spacer(flex: 3),
          const Text("Already have an account? Sign In here."),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_right_rounded),
          const Spacer(),
        ], colors: colors, onPressed: _handleClickLoginUser),
      ],
    );
  }
}
