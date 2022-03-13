import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/login/login_screen.dart';
import 'package:solidtrade/services/util/util.dart';

class LoginSignUp extends StatefulWidget {
  const LoginSignUp({Key? key}) : super(key: key);

  @override
  State<LoginSignUp> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> with STWidget {
  String _dicebearSeed = "your-custom-seed";
  late String _tempCurrentSeed;

  Future<void> _handleChangeSeed(String seed) async {
    if (seed.length > 100) {
      return;
    }

    _tempCurrentSeed = seed;

    await Future.delayed(const Duration(milliseconds: 400));

    if (_tempCurrentSeed != seed) {
      return;
    }

    setState(() {
      _dicebearSeed = seed;
    });
  }

  void _handleClickUploadImage() {}

  void _handleClickContinueSignUp() {
    // TODO: Verify that user has logged in with its google account.
    // Not not open popup again. If it successes, then continue else open popup saying that it google login failed
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      imageUrl: "https://avatars.dicebear.com/api/micah/$_dicebearSeed.svg",
      title: "Welcome to Solidtrade!",
      subTitle: "Ready to create your solidtrade profile? Let's start with your profile picture!\nType a custom seed to generate a picture or upload your own custom image.",
      additionalWidgets: [
        // Util.roundedButton(
        //   [
        //     Util.loadImage(
        //       "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1200px-Google_%22G%22_Logo.svg.png",
        //       20,
        //     ),
        //     const SizedBox(width: 10),
        //     const Text(
        //       "Google account linked. Click here to change.",
        //       overflow: TextOverflow.fade,
        //       maxLines: 1,
        //       softWrap: false,
        //     ),
        //   ],
        //   colors: colors,
        //   onPressed: _handleClickLoginWithGoogle,
        // ),
        SizedBox(
          child: TextFormField(
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(10),
              border: OutlineInputBorder(),
              hintText: 'Why not enter your name 😉',
            ),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
            initialValue: _dicebearSeed,
            onChanged: _handleChangeSeed,
          ),
        ),
        const SizedBox(height: 10),
        Util.roundedButton(
          [
            const SizedBox(width: 2),
            const Text(
              "Or upload own picture. GIFs are also supported!",
            ),
            const SizedBox(width: 2),
          ],
          colors: colors,
          onPressed: _handleClickUploadImage,
        ),
        const SizedBox(height: 10),
        Util.roundedButton(
          [
            const Spacer(flex: 3),
            const Text("Looks good? Continue here"),
            const Spacer(),
            const Icon(Icons.chevron_right),
            const Spacer(),
          ],
          colors: colors,
          // foregroundColor: colors.background,
          // backgroundColor: colors.darkGreen,
          onPressed: _handleClickContinueSignUp,
        ),
      ],
    );
  }
}
