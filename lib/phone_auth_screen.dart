import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isReturningUser = false;
  bool _isLoading = true;
  bool _isSendingCode = false;

  String? sentOtp;  // Store the sent OTP here for validation

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+91 '; // Default to India code
    _checkUserSession();
  }

  void _checkUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPhoneNumber = prefs.getString('phoneNumber');
    String? storedName = prefs.getString('name');

    if (storedPhoneNumber != null) {
      setState(() {
        _isReturningUser = true;
        _phoneController.text = storedPhoneNumber;
        _nameController.text = storedName ?? '';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> sendVerificationCode() async {
    String phone = _phoneController.text.trim(); // Remove the leading country code or spaces

    // Remove country code (if any) and ensure only the last 10 digits are used
    if (phone.startsWith('+91')) {
      phone = phone.substring(3); // Remove the '+91' country code
    }

    // Ensure that only the last 10 digits are included
    if (phone.length > 10) {
      phone = phone.substring(phone.length - 10); // Take only the last 10 digits
    }

    if (phone.length < 10) {
      _showErrorDialog('Please enter a valid phone number');
      return;
    }

    print('Phone: $phone');  // Print the phone number

    setState(() {
      _isSendingCode = true;
    });

    final url = Uri.parse("https://portal.gradsgateway.com/api/mobileotp?mobile=$phone");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData');

        // If responseData is a direct OTP value, you don't need to use ['otp']
        sentOtp = responseData.toString();  // Convert OTP (if it's an int) to string
        print('Sent OTP: $sentOtp');

        // Navigate to OTP screen after sending code
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phone: _phoneController.text, // Keep the full phone number (with country code if entered)
              name: _nameController.text,
              sentOtp: sentOtp,
            ),
          ),
        );
      } else {
        _showErrorDialog('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Error sending OTP: $e');
      print('Error: $e');
    } finally {
      setState(() {
        _isSendingCode = false;
      });
    }
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
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sign In', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isReturningUser)
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                          ),
                        if (!_isReturningUser) SizedBox(height: 20),
                        TextFormField(

                          maxLength: 12,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,  // Allow only digits
                          ],
                          enabled: !_isReturningUser,
                          controller: _phoneController,
    buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) {
    return null; // This hides the character counter
    },
                          decoration: InputDecoration(labelText: 'Enter phone number', border: OutlineInputBorder()),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0FB7C6), // Set background color to blue
                ),
                onPressed: !_isSendingCode ? sendVerificationCode : null,
                child: _isSendingCode
                    ? CircularProgressIndicator()
                    : Text('Send OTP', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
