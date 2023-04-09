import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solidtrade/components/base/st_page.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/common/st_logo.dart';
import 'package:solidtrade/components/custom/input_field.dart';
import 'package:solidtrade/pages/home/home_page.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/get_it.dart';
import 'package:solidtrade/services/util/util.dart';

class ContinueSignupScreen extends StatefulWidget {
  const ContinueSignupScreen({
    Key? key,
    required this.dicebearSeed,
    required this.profilePictureBytes,
    required this.email,
  }) : super(key: key);
  final Uint8List? profilePictureBytes;
  final String? dicebearSeed;
  final String email;

  @override
  State<ContinueSignupScreen> createState() => _ContinueSignupScreenState();
}

class _ContinueSignupScreenState extends State<ContinueSignupScreen> with STWidget {
  final TextEditingController _initialBalanceController = TextEditingController(text: 10000.toString());
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final historicalPositionService = get<HistoricalPositionService>();
  final portfolioService = get<PortfolioService>();
  final userService = get<UserService>();

  Future<void> _handleClickCreateAccount() async {
    final closeDialog = Util.showLoadingDialog(context);

    String name = _nameController.text;
    String username = _usernameController.text;
    int initialBalance = int.parse(_initialBalanceController.text);

    var response = await userService.createUser(
      name,
      username,
      widget.email,
      initialBalance,
      profilePictureSeed: widget.dicebearSeed,
      profilePictureFile: widget.profilePictureBytes,
    );

    if (response.isSuccessful) {
      final userId = response.result!.id;
      await historicalPositionService.fetchHistoricalPositions(userId);
      await portfolioService.fetchPortfolioByUserId(userId);

      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      return;
    }

    closeDialog();

    Util.openDialog(context, 'Could not create user', message: response.error!.userFriendlyMessage);
  }

  @override
  Widget build(BuildContext context) {
    return STPage(
      page: () => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: colors.splashScreenColor,
        body: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    STLogo(colors.logoAsGif, key: UniqueKey(), animationDuration: const Duration(seconds: 0)),
                    const SizedBox(height: 25),
                    const Text(
                      'Hey friend👋\nOnly a few steps remaining\n\nChoose a name and define how much cash you want to start with!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: InputField(
                        controller: _nameController,
                        labelText: 'Name',
                        hintText: 'John Doe',
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: InputField(
                        controller: _usernameController,
                        labelText: 'Username',
                        hintText: 'john_doe',
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: InputField(
                        controller: _initialBalanceController,
                        labelText: 'Starting account balance',
                        hintText: '10000',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: Util.roundedButton(
                        [
                          const Text('Create account!')
                        ],
                        onPressed: _handleClickCreateAccount,
                        colors: colors,
                        backgroundColor: DarkColorTheme().navigationBackground,
                        foregroundColor: DarkColorTheme().foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
