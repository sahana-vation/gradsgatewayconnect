import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';


class OtpScreen extends StatefulWidget {
  final String phone;
  final String name;
  final String? sentOtp;  // Accept sent OTP

  OtpScreen({required this.phone, required this.name, this.sentOtp});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifyingOtp = false;

  Future<void> verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 4) {
      _showErrorDialog('Please enter a valid OTP');
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
    });

    // Compare entered OTP with sent OTP
    if (otp == widget.sentOtp) {
      debugPrint('OTP Verified Successfully');

      // Save the user session and navigate to the home screen
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('phoneNumber', widget.phone);
      await prefs.setString('name', widget.name);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            name: widget.name,
            phoneNumber: widget.phone,
          ),
        ),
      );
    } else {
      _showErrorDialog('Invalid OTP. Please try again.');
    }

    setState(() {
      _isVerifyingOtp = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1F5FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: SvgPicture.asset(
          'assets/icon/gg logo.svg',
          width: 32,
          height: 32,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter OTP', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            SizedBox(height: 20,),
            Expanded(
              child:
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,  // Allow only numeric input
                maxLength: 4,  // Restrict input to 4 digits
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,  // Allow only digits
                ],
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                  counterText: '',  // Hide the counter text for the maxLength
                ),
              ),

            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0FB7C6), // Set background color to blue
                ),
                onPressed: _isVerifyingOtp ? null : verifyOtp,
                child: _isVerifyingOtp
                    ? CircularProgressIndicator()
                    : Text('Verify OTP', style: TextStyle(color: Colors.white)),
              ),
            ),

          ],
        ),
      ),
    );
  }
}


