import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradsgatewayconnect/home.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:otp_autofill/otp_autofill.dart';

class OtpBottomSheet extends StatefulWidget {
  final String phone;
  final String sentOtp;

  const OtpBottomSheet({Key? key, required this.phone, required this.sentOtp}) : super(key: key);

  @override
  _OtpBottomSheetState createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> with CodeAutoFill {
  bool _isVerifyingOtp = false;
  bool _isResendingOtp = false;
  String currentOtp = '';
  late OTPInteractor _otpInteractor;
  late OTPTextEditController otpController;

  @override
  void initState() {
    super.initState();
    // requestSmsPermission();
    currentOtp = widget.sentOtp;
    _initInterceptor();

    otpController = OTPTextEditController(
      codeLength: 4, // Adjust OTP length based on backend response
      onCodeReceive: (code) {
        log('Received OTP: $code');
        setState(() {
          otpController.text = code;
        });
        verifyOtp(); // Auto-submit OTP
      },
      otpInteractor: _otpInteractor,
    )..startListenUserConsent((code) {
      final exp = RegExp(r'(\d{4})'); // Ensure the regex matches the OTP format
      return exp.stringMatch(code ?? '') ?? '';
    });
  }

  /// Initializes OTP Interceptor
  Future<void> _initInterceptor() async {
    _otpInteractor = OTPInteractor();
    final appSignature = await _otpInteractor.getAppSignature();
    log('App Signature: $appSignature');
  }

  @override
  void codeUpdated() {
    if (code != null && code!.length == 4) {
      setState(() {
        otpController.text = code!;
      });
      verifyOtp(); // Auto-submit OTP
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    cancel();
    super.dispose();
  }

  /// Function to Show Error Dialog
  void _showErrorDialog(String message) {
    if (!mounted) return;

    // Close any existing dialogs before opening a new one
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close only this dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }



  /// Function to Verify OTP
  Future<void> verifyOtp() async {
    final otp = int.tryParse(otpController.text.trim()); // ✅ Directly access .text

    if (otp == null || otp.toString().length != 4) {
      _showErrorDialog('Please enter a valid 4-digit OTP.');
      return;
    }

    if (currentOtp.isEmpty) {
      _showErrorDialog('Invalid OTP received from the server.');
      return;
    }

    // ✅ Fix JSON format (if needed)
    String fixedJson = currentOtp.replaceAllMapped(
        RegExp(r'(\w+):'),
            (match) => '"${match.group(1)}":' // Add quotes around JSON keys
    );

    debugPrint("Fixed OTP JSON: $fixedJson");

    // ✅ Decode the fixed JSON
    Map<String, dynamic> otpResponse;
    try {
      otpResponse = json.decode(fixedJson);
    } catch (e) {
      _showErrorDialog('Failed to parse OTP response.');
      debugPrint("OTP Parse Error: ${e.toString()} | Response: $fixedJson");
      return;
    }

    // Extract OTP
    final int? serverOtp = otpResponse['otp'] is int
        ? otpResponse['otp']
        : int.tryParse(otpResponse['otp'].toString());

    if (serverOtp == null) {
      _showErrorDialog('OTP response is missing the OTP value.');
      return;
    }

    debugPrint('Entered OTP: $otp');
    debugPrint('Server OTP: $serverOtp');

    setState(() {
      _isVerifyingOtp = true;
    });

    await Future.delayed(Duration(seconds: 2));

    if (otp == serverOtp) {
      debugPrint('OTP Verified Successfully');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('phoneNumber', widget.phone);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(phoneNumber: widget.phone),
        ),
      );
    } else {
      _showErrorDialog('Invalid OTP. Please try again.');
    }

    setState(() {
      _isVerifyingOtp = false;
    });
  }


  /// Function to Resend OTP
  Future<void> resendOtp() async {
    setState(() {
      _isResendingOtp = true;
    });

    final url = Uri.parse("https://portal.gradsgateway.com/api/signinnew?mobile=${widget.phone}");

    try {
      final response = await http.post(url);
      log("Response Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData["Message"] == "Please signup before signing in.") {
          _showErrorDialog("Please sign up before signing in.");
        } else {
          String newOtp = responseData.toString();
          log("Received New OTP Response: $newOtp");
          setState(() {
            currentOtp = newOtp; // Update OTP
          });
        }
      } else {
        _showErrorDialog('Failed to resend OTP. Please try again.');
      }
    } catch (e) {
      log("Error resending OTP: $e");
      _showErrorDialog('Error resending OTP: $e');
    } finally {
      setState(() {
        _isResendingOtp = false;
      });
    }
  }

  /// OTP Input Field using Pinput


  Widget otpField(BuildContext context, TextEditingController otpController) {
    return Pinput(
      autofillHints: [AutofillHints.oneTimeCode],
      length: 4,
      controller: otpController,
      defaultPinTheme: PinTheme(
        height: 50,
        width: 50,
        textStyle: const TextStyle(fontSize: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8.0), // Square-like corners
        ),
      ),
      focusedPinTheme: PinTheme(
        height: 50,
        width: 50,
        textStyle: const TextStyle(fontSize: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8.0), // Keeps square-like corners
        ),
      ),
      submittedPinTheme: PinTheme(
        height: 50,
        width: 50,
        textStyle: const TextStyle(fontSize: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onCompleted: (pin) {
        if (pin.length == 4) {
          verifyOtp();
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -38,
          left: (MediaQuery.of(context).size.width - 100) / 2,
          child: Image.asset(
            'assets/images/Group (4).png',
            width: 100,
            height: 106,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text("Enter OTP",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                "Sign in code has been sent to +91${widget.phone},\ncheck your inbox to continue the sign process.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              otpField(context, otpController),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _isResendingOtp ? null : resendOtp,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Haven't received the sign code?"),
                    Text(
                      _isResendingOtp ? " Resending..." : " Resend it.",
                      style: TextStyle(color: Color(0xFF0FB7C6), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0FB7C6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  onPressed: _isVerifyingOtp ? null : verifyOtp,
                  child: _isVerifyingOtp
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

/// Function to Show OTP Bottom Sheet
void showOtpBottomSheet(BuildContext context, String phone, String sentOtp) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => OtpBottomSheet(phone: phone, sentOtp: sentOtp),
  );
}
Future<void> requestSmsPermission() async {
  var status = await Permission.sms.status;
  if (!status.isGranted) {
    await Permission.sms.request();
  }
}