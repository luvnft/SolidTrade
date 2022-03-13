import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/shared/st_logo.dart';
import 'package:solidtrade/pages/login_page.dart';
import 'package:solidtrade/pages/settings_page.dart';
import 'package:solidtrade/providers/language/translation.dart';
import 'package:solidtrade/services/util/debug/log.dart';
import 'package:solidtrade/services/util/util.dart';

import 'dart:typed_data';
import 'package:http/http.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with STWidget {
  void _handleClickSettings() {
    Util.pushToRoute(context, SettingsPage());
  }

  void _handleClickContinue() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ));
  }

  Iterable<AnimatedText> getWelcomeMessages(BuildContext context) {
    return SharedTranslations.welcomeMessages.map((message) => FadeAnimatedText(
          message,
          textStyle: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 40),
          textAlign: TextAlign.center,
        ));
  }

  TyperAnimatedText getSolidtradeText(BuildContext context) {
    return TyperAnimatedText("Solidtrade™", textStyle: Theme.of(context).textTheme.headline5, speed: const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: uiUpdate.stream$,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: colors.splasScreenColor,
          body: Column(
            children: [
              const Spacer(flex: 2),
              STLogo(
                colors.logoAsGif,
                key: UniqueKey(),
              ),
              const Spacer(),
              SizedBox(
                height: 55,
                child: AnimatedTextKit(
                  repeatForever: true,
                  pause: const Duration(seconds: 0),
                  animatedTexts: [
                    ...getWelcomeMessages(context),
                  ],
                ),
              ),
              AnimatedTextKit(
                key: UniqueKey(),
                totalRepeatCount: 1,
                animatedTexts: [
                  getSolidtradeText(context)
                ],
              ),
              const Spacer(),
              Util.roundedButton([
                const SizedBox(width: 20),
                Text("Ready?", style: TextStyle(color: colors.background)),
                SizedBox(child: Icon(Icons.keyboard_arrow_right_rounded, color: colors.background)),
                const SizedBox(width: 10),
              ], onPressed: _handleClickContinue, colors: colors, backgroundColor: colors.foreground),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  child: TextButton(
                    child: Icon(Icons.settings, color: colors.foreground),
                    onPressed: _handleClickSettings,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class NonCacheNetworkImage extends StatelessWidget {
  const NonCacheNetworkImage(this.imageUrl, {Key? key}) : super(key: key);
  final String imageUrl;
  Future<Uint8List> getImageBytes() async {
    Response response = await get(Uri.parse(imageUrl));
    return response.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: getImageBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            height: 100.0,
            width: 100.0,
          );
        }
        return const SizedBox(
          height: 100.0,
          width: 100.0,
        );
      },
    );
  }
}
