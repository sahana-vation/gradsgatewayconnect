import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gradsgatewayconnect/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  void _checkUserLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPhoneNumber = prefs.getString('phoneNumber');
    String? storedName = prefs.getString('name');

    log('Retrieved phoneNumber: $storedPhoneNumber');
    log('Retrieved name: $storedName');

    Future.delayed(const Duration(seconds: 3), () {
      if (storedPhoneNumber != null && storedPhoneNumber.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              phoneNumber: storedPhoneNumber,
              name: storedName ?? 'User',
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/OB8h0yydDb.gif',
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
