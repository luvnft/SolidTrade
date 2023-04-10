import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/common/st_logo.dart';

class Splash extends StatefulWidget {
  const Splash({required this.shouldRedirectToLogin, required this.child, Key? key}) : super(key: key);
  final bool? shouldRedirectToLogin;
  final Widget? child;

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with STWidget {
  bool _alreadyRedirected = false;
  bool _visible = false;

  void _fade() {
    setState(() {
      _visible = !_visible;
    });
  }

  PageRouteBuilder<T> _createPageRouteBuilder<T>(Offset? begin, Widget widget) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 1250),
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: begin, end: Offset.zero).chain(
          CurveTween(curve: Curves.ease),
        );
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  Future<void> navigate() async {
    if (widget.shouldRedirectToLogin!) {
      _fade();

      // Wait for the typewriter to finish
      await Future.delayed(const Duration(seconds: 6));
    }

    var route = _createPageRouteBuilder(const Offset(0.0, 1.0), widget.child!);
    await Future.delayed(const Duration(milliseconds: 200));
    Navigator.of(context).pushReplacement(route);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shouldRedirectToLogin != null && !_alreadyRedirected) {
      _alreadyRedirected = true;
      navigate();
    }

    return Scaffold(
      backgroundColor: colors.splashScreenColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Spacer(),
            STLogo(colors.logoAsGif, key: UniqueKey()),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                _visible
                    ? SizedBox(
                        height: 50,
                        child: AnimatedTextKit(
                          totalRepeatCount: 1,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Welcome to',
                              speed: const Duration(milliseconds: 100),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                            TypewriterAnimatedText(
                              'Solidtrade™',
                              speed: const Duration(milliseconds: 100),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(height: 50),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
