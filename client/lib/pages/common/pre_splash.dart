import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/pages/common/splash.dart';
import 'package:solidtrade/pages/common/welcome_page.dart';
import 'package:solidtrade/pages/home/home_page.dart';

class PreSplash extends StatefulWidget {
  const PreSplash({Key? key}) : super(key: key);

  @override
  State<PreSplash> createState() => PreSplashState();
}

class PreSplashState extends State<PreSplash> with STWidget {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _loadSplashScreen();
    });
  }

  void _loadSplashScreen() async {
    var routeBuilderSplashScreen = _createPageRouteBuilder<bool>(const Offset(0.0, -1.0), const Splash());
    var fetchUserWasSuccessful = await Navigator.of(context).push<bool>(routeBuilderSplashScreen);

    if (fetchUserWasSuccessful == null) {
      throw "Did not expect navigation result to not be null";
    }

    // If fetching the user failed, we reauthenticate.
    if (!fetchUserWasSuccessful) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomePage()));
      return;
    }

    // If fetching the user succeeded, we navigate to the home screen.
    var routeBuilderToHome = _createPageRouteBuilder(const Offset(0.0, 1.0), const HomePage());
    await Future.delayed(const Duration(milliseconds: 200));
    Navigator.of(context).pushReplacement(routeBuilderToHome);
  }

  PageRouteBuilder<T> _createPageRouteBuilder<T>(Offset? begin, Widget widget) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(seconds: 1),
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

  @override
  Widget build(BuildContext context) {
    return Container(color: colors.splashScreenColor);
  }
}
