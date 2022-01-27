import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/pages/home_page.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with STWidget {
  final historicalPositionService = GetIt.instance.get<HistoricalPositionService>();
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    _fadeContent();
    _navigateToHome();
  }

  void _fadeContent() {
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _visible = !_visible;
      });
    });
  }

  Future<void> _navigateToHome() async {
    // await Future.delayed(const Duration(milliseconds: 300));
    await Future.delayed(const Duration(seconds: 5));

    // TODO: Remove user id here in the future.
    await historicalPositionService.fetchHistoricalPositions(11003);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Spacer(),
            Image.asset(
              colors.logoAsGif,
              height: 100.0,
              width: 100.0,
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text('Loading...'),
                  SizedBox(
                    width: 220,
                    child: Divider(thickness: 2, color: colors.softForeground),
                  ),
                  const Text('Solid trade'),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
