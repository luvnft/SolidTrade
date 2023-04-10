import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solidtrade/components/base/st_page.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/custom/input_field.dart';
import 'package:solidtrade/components/custom/timer_button.dart';
import 'package:solidtrade/data/dtos/auth/response/check_magic_link_status_response_dto.dart';
import 'package:solidtrade/data/models/common/constants.dart';
import 'package:solidtrade/data/models/enums/client_enums/preferences_keys.dart';
import 'package:solidtrade/pages/home/home_page.dart';
import 'package:solidtrade/pages/signup_and_signin/base/login_page.dart';
import 'package:solidtrade/providers/language/shared/shared_welcome_messages.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/get_it.dart';
import 'package:solidtrade/services/util/util.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with STWidget {
  final _historicalPositionService = get<HistoricalPositionService>();
  final _secureStorage = get<FlutterSecureStorage>();
  final _portfolioService = get<PortfolioService>();
  final _emailController = TextEditingController();
  final _userService = get<UserService>();

  DateTime _lastMailSend = DateTime.fromMicrosecondsSinceEpoch(0);
  bool _showResendButton = false;

  void _handleClickChangeLanguage() {
    UtilCupertino.showCupertinoDialog(
      context,
      title: 'Language',
      message: 'Choose a language',
      widgets: UtilCupertino.languageActionSheets(context, configurationProvider.languageProvider),
    );
  }

  void _handleClickChangeTheme() {
    configurationProvider.themeProvider.updateTheme(colors.themeColorType.isLight ? ColorThemeType.dark : ColorThemeType.light);
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

  Future<void> _handleClickSendMagicLink() async {
    final email = _emailController.text.trim();
    final isValidMail = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(email);

    if (!isValidMail) {
      const snackBar = SnackBar(
        content: Text('Seems like you entered an invalid email address. Please try again.'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (_lastMailSend.add(const Duration(seconds: 30)).isAfter(DateTime.now())) {
      const snackBar = SnackBar(
        content: Text('Please wait a few seconds before sending another link.'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final createLinkResponse = await DataRequestService.authDataRequestService.createMagicLink(email);

    _lastMailSend = DateTime.now();

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

    setState(() {
      _showResendButton = false;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _showResendButton = true;
    });

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
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(email: email)));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      }

      snk.close();
      return;
    }
  }

  void _handleClickLostEmail() {
    launchUrl(Uri.parse(Constants.forgotOrLostAccountFormLink));
  }

  Iterable<AnimatedText> _getWelcomeMessages(BuildContext context) {
    return SharedWelcomeMessages.welcomeMessages.map((message) => FadeAnimatedText(
          message,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          textAlign: TextAlign.center,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return STPage(
      page: () => Scaffold(
        backgroundColor: colors.splashScreenColor,
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    IconButton(
                      icon: Icon(colors.themeColorType.isLight ? Icons.nightlight : Icons.brightness_7),
                      onPressed: _handleClickChangeTheme,
                    ),
                    IconButton(
                      icon: const Icon(Icons.language),
                      onPressed: _handleClickChangeLanguage,
                    ),
                  ]),
                  const SizedBox(height: 35),
                  SizedBox(
                    height: 40,
                    child: AnimatedTextKit(
                      repeatForever: true,
                      pause: const Duration(seconds: 0),
                      animatedTexts: [
                        ..._getWelcomeMessages(context),
                      ],
                    ),
                  ),
                  const Text('The perfect platform for losing money with your friends.'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: InputField(
                      controller: _emailController,
                      hintText: 'example@mail.com',
                      labelText: 'Email',
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(onPressed: _handleClickLostEmail, child: const Text('Can\'t access Email?', style: TextStyle(color: Colors.blue))),
                      const Spacer(),
                      _showResendButton
                          ? TimerButton(
                              onPressed: _handleClickSendMagicLink,
                              text: 'Resend login link',
                              initialSecondsLeft: 30,
                            )
                          : const SizedBox.shrink(),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              Util.roundedButton(
                [
                  Text('Send login link to email', style: TextStyle(color: colors.themeColorType.isDark ? colors.foreground : Colors.white)),
                ],
                onPressed: _handleClickSendMagicLink,
                backgroundColor: colors.themeColorType.isDark ? colors.softBackground : colors.foreground,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
