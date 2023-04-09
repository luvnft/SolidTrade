import 'package:flutter/material.dart';
import 'package:solidtrade/pages/signup_and_signin/signup/login_signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({required this.email, Key? key}) : super(key: key);
  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(margin: const EdgeInsets.all(8.0), child: LoginSignUp(email: email)),
    );
  }
}
