import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'home.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String name;
  final String? sentOtp;

  OtpScreen({required this.phone, required this.name, this.sentOtp});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifyingOtp = false;
  FocusNode _otpFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    listenForCode(); // Start listening for OTP code
  }

  @override
  void codeUpdated() {
    setState(() {
      _otpController.text = code ?? ''; // Auto-update OTP input field
      debugPrint('Auto-filled OTP: $code');

      // Automatically move the focus to the next input field if OTP is complete
      if (code?.length == 4) {
        FocusScope.of(context).requestFocus(FocusNode()); // Remove focus from the current OTP field
        verifyOtp(); // Automatically verify once all digits are entered
      }
    });
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener(); // Clean up the listener
    _otpFocusNode.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 4) {
      _showErrorDialog('Please enter a valid OTP');
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
    });

    if (otp == widget.sentOtp) {
      debugPrint('OTP Verified Successfully');

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
          width: 40,
          height: 40,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter OTP', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                SizedBox(height: 20),
                PinFieldAutoFill(
                  controller: _otpController,
                  codeLength: 4, // Number of OTP digits
                  focusNode: _otpFocusNode, // Assign the focus node to the field
                  onCodeChanged: (code) {
                    if (code?.length == 4) {
                      debugPrint('Entered OTP: $code');
                      verifyOtp(); // Automatically verify once all digits are entered
                    }
                  },
                  decoration: BoxLooseDecoration(
                    strokeWidth: 1,
                    gapSpace: 10,
                    radius: Radius.circular(5),
                    textStyle: TextStyle(fontSize: 20, color: Colors.black),
                    bgColorBuilder: FixedColorBuilder(Colors.white), // Background color of each box
                    strokeColorBuilder: FixedColorBuilder(Colors.black), // Border color of each box
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0FB7C6),
                ),
                onPressed: _isVerifyingOtp ? null : verifyOtp,
                child: _isVerifyingOtp
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Verify OTP', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
