import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gradsgatewayconnect/widgets/sing_up_bottom_Sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'widgets/sign_in_bottom_sheet.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  // Function to check user login status and navigate
  void _checkUserLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPhoneNumber = prefs.getString('phoneNumber');
    String? storedName = prefs.getString('name');

    log('Retrieved phoneNumber: $storedPhoneNumber');
    log('Retrieved name: $storedName');

    // If user is already logged in, navigate directly to HomeScreen
    if (storedPhoneNumber != null && storedPhoneNumber.isNotEmpty) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              phoneNumber: storedPhoneNumber,
              name: storedName ?? 'User',
            ),
          ),
        );
      });
    } else {
      // If user is not logged in, show Sign In bottom sheet
      // Future.delayed(const Duration(seconds: 2), () {
      //   if (mounted) {
      //     // Only show the bottom sheet if the user is not logged in
      //     showSignInBottomSheet(context);
      //   }
      // });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extends background to status bar
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: -197,
            left: -49,
            child: Image.asset(
              'assets/images/pexels-monirathnak-13632459 1 (1).png',
              width: 478,
              height: 650,
              fit: BoxFit.contain,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.only(top: 430.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Group 22.png',
                    width: 261,
                    height: 42,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 326,
                    height: 48,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100), // Ensures ripple effect follows button shape
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool('isLoggedIn', true); // Store login status
                        showSignInBottomSheet(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0FB7C6),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Inter",
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: 326,
                    height: 48,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100), // Ensures ripple effect follows button shape
                      onTap: () => showSignUpBottomSheet(context), // Same action as the button
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xFF0FB7C6),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF0FB7C6),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Inter",
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'By logging in or registering, you agree to our',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/privacyPolicy');
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Privacy policy.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0FB7C6),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
