import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradsgatewayconnect/privacy_policy_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'phone_auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Function to check user login status and navigate
  void _checkUserLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPhoneNumber = prefs.getString('phoneNumber');
    String? storedName = prefs.getString('name');

    if (storedPhoneNumber != null && storedName != null) {
      // User is already logged in, navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            phoneNumber: storedPhoneNumber,
            name: storedName,
          ),
        ),
      );
    } else {
      // New user, navigate to PhoneAuthScreen for sign-up/login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PhoneAuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: SvgPicture.asset(
          'assets/icon/gg logo.svg',
          width: 40,
          height: 40,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  'Welcome to Grads\nGateway!',
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/icon/Group 24.png',
                width: screenSize.width,
                height: screenSize.height * 0.5,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 45),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: _checkUserLoginStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF042628),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sign In ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Poppins',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPolicyScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Privacy policy.',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF0FB7C6),
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
    );
  }
}
