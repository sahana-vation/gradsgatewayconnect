import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = true;
  bool _isSendingCode = false;
  String? sentOtp;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  void _checkUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _phoneController.text = prefs.getString('phoneNumber') ?? '';
    _nameController.text = prefs.getString('name') ?? '';
    setState(() => _isLoading = false);
  }

  Future<void> sendVerificationCode() async {
    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();

    if (phone.startsWith('+91')) phone = phone.substring(3);
    if (phone.length > 10) phone = phone.substring(phone.length - 10);
    if (phone.length < 10) {
      _showErrorDialog('Please enter a valid phone number');
      return;
    }

    // Save the name and phone number in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phone);
    await prefs.setString('name', name);
    log('Saved phoneNumber: $phone');
    log('Saved name: $name');


    setState(() => _isSendingCode = true);

    final url = Uri.parse("https://portal.gradsgateway.com/api/signup?mobile=$phone&name=$name");

    try {
      final response = await http.post(url);
      log("Response Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody["Message"] == "You are already signed up. Please sign in") {
          _showAlreadySignedUpDialog();
        } else {
          sentOtp = responseBody.toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                phone: _phoneController.text,
                sentOtp: sentOtp,
              ),
            ),
          );
        }
      } else {
        _showErrorDialog('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Error sending OTP: $e');
    } finally {
      setState(() => _isSendingCode = false);
    }
  }


  void _showAlreadySignedUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Already Signed Up"),
        content: Text("You are already signed up. Please sign in."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pop(context); // Navigate back to the previous screen
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1F5FE),
        elevation: 0,
        title: SvgPicture.asset('assets/icon/gg logo.svg', width: 40, height: 40),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Spacer(),
            Text('Sign Up', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Enter Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: 'Enter Phone Number', border: OutlineInputBorder()),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !_isSendingCode ? sendVerificationCode : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF042628),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSendingCode
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Sign Up', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
