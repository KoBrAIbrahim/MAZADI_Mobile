import 'package:application/screens/Forget_Password/forget_page.dart';
import 'package:application/screens/Phone_verification_page.dart/OTP_verification_page.dart';
import 'package:application/screens/signup_Pages/account_signup_page.dart';
import 'package:application/screens/signup_Pages/confirm_signup_page.dart';
import 'package:application/screens/signup_Pages/info_signup_page.dart';
import 'package:application/screens/Login_Pages/login_page.dart';
import 'package:application/screens/welcome_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MazadiApp());
}

class MazadiApp extends StatelessWidget {
  const MazadiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مزادي',
      theme: ThemeData(
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const VerificationCodePage(),
    );
  }
}
