import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/dtos/auth/response/check_magic_link_status_response_dto.dart';
import 'package:solidtrade/data/models/common/constants.dart';
import 'package:solidtrade/data/models/enums/client_enums/preferences_keys.dart';
import 'package:solidtrade/pages/home/home_page.dart';
import 'package:solidtrade/pages/signup_and_signin/components/login_screen.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/get_it.dart';
import 'package:solidtrade/services/util/util.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginSignIn extends StatefulWidget {
  const LoginSignIn({Key? key}) : super(key: key);

  @override
  State<LoginSignIn> createState() => _LoginSignInState();
}

class _LoginSignInState extends State<LoginSignIn> with STWidget {
  final _secureStorage = get<FlutterSecureStorage>();
  final _historicalPositionService = GetIt.instance.get<HistoricalPositionService>();
  final _portfolioService = GetIt.instance.get<PortfolioService>();
  final _userService = GetIt.instance.get<UserService>();

  String _email = '';

  Future<void> _handleClickSendLoginLink(BuildContext context) async {
    final email = _email.trim();
    final isValidMail = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(email);

    if (!isValidMail) {
      const snackBar = SnackBar(
        content: Text('Seems like you entered an invalid email address. Please try again.'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final createLinkResponse = await DataRequestService.authDataRequestService.createMagicLink(email);

    if (!createLinkResponse.isSuccessful) {
      Util.openDialog(context, 'Failed to send link', message: createLinkResponse.error!.userFriendlyMessage);
      return;
    }

    final code = createLinkResponse.result!.confirmationStatusCode;

    const snackBar = SnackBar(
      content: Text('A login link was send to your email address. Please click on the link to login.'),
      duration: Duration(days: 1),
      showCloseIcon: true,
    );

    final snk = ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Once the link was send we wait for the user to confirm the link
    // we do this by polling. this is not pretty but it works
    while (true) {
      await Future.delayed(const Duration(seconds: 5));

      final statusResponse = await DataRequestService.authDataRequestService.checkMagicLinkStatus(code);

      if (!statusResponse.isSuccessful) {
        Util.openDialog(context, 'Failed to verify code', message: statusResponse.error!.userFriendlyMessage);
        return;
      }

      final status = statusResponse.result!.status;

      if (status == MagicLinkStatus.magicLinkNotClicked) {
        continue;
      }

      final tokens = statusResponse.result!.tokens!;
      await _secureStorage.write(key: SecureStorageKeys.token.name, value: tokens.token);
      await _secureStorage.write(key: SecureStorageKeys.refreshToken.name, value: tokens.refreshToken);

      final fetchedSuccessfully = await _fetchUser();

      if (!fetchedSuccessfully) {
        Util.openDialog(context, 'Failed to login', message: 'Something went wrong while logging in. Are you sure you have an account?\nIf so try again later.');
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      }

      snk.close();
      return;
    }
  }

  Future<bool> _fetchUser() async {
    var userRequest = await _userService.fetchUserCurrentUser();
    if (userRequest.isSuccessful) {
      await _historicalPositionService.fetchHistoricalPositions(userRequest.result!.id);
      await _portfolioService.fetchPortfolioByUserId(userRequest.result!.id);
      return true;
    }

    return false;
  }

  Future<void> _handleClickForgotOrLostAccount() async => await launchUrl(Uri.parse(Constants.forgotOrLostAccountFormLink));

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      imageUrl: Constants.smokingGif,
      title: 'Hello Again!',
      subTitle: "Welcome back you've been missed!",
      additionalWidgets: [
        TextField(
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(),
            hintText: 'example@mail.com',
          ),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
          onChanged: (value) => _email = value,
        ),
        const SizedBox(height: 10),
        Util.roundedButton(
          [
            const Text('Send login link to email'),
          ],
          colors: colors,
          onPressed: () => _handleClickSendLoginLink(context),
        ),
        const SizedBox(height: 10),
        Util.roundedButton(
          [
            const Text('Forgot or lost your Account? Click here!'),
          ],
          colors: colors,
          onPressed: _handleClickForgotOrLostAccount,
        ),
      ],
    );
  }
}
