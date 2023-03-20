import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solidtrade/pages/common/welcome_page.dart';
import 'package:solidtrade/pages/home/home_page.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/get_it.dart';

enum _LoginState {
  loggedIn,
  loggedOut,
}

class InitialLoadingPage extends StatefulWidget {
  const InitialLoadingPage({Key? key}) : super(key: key);

  @override
  State<InitialLoadingPage> createState() => _InitialLoadingPageState();
}

class _InitialLoadingPageState extends State<InitialLoadingPage> {
  final _historicalPositionService = get<HistoricalPositionService>();
  final _portfolioService = get<PortfolioService>();
  final _userService = get<UserService>();

  final _fetchedUserSuccessfully = Completer<_LoginState>();

  @override
  void initState() {
    _fetchUser();
    super.initState();
  }

  Future<void> _fetchUser() async {
    var userRequest = await _userService.fetchUserCurrentUser();
    if (userRequest.isSuccessful) {
      await _historicalPositionService.fetchHistoricalPositions(userRequest.result!.id);
      await _portfolioService.fetchPortfolioByUserId(userRequest.result!.id);
      _fetchedUserSuccessfully.complete(_LoginState.loggedIn);

      return;
    }

    _fetchedUserSuccessfully.complete(_LoginState.loggedOut);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchedUserSuccessfully.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          switch (snapshot.data!) {
            case _LoginState.loggedIn:
              return const HomePage();
            case _LoginState.loggedOut:
              return const WelcomePage();
          }
        }

        return const Scaffold(body: Center(child: Text('Loading')));
      },
    );
  }
}
