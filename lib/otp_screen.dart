// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms_autofill/sms_autofill.dart';
// import 'dummy.dart';
// import 'home.dart';
//
// class OtpScreen extends StatefulWidget {
//   final String phone;
//
//   final String? sentOtp;
//
//   OtpScreen({required this.phone,  this.sentOtp});
//
//   @override
//   _OtpScreenState createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
//   final TextEditingController _otpController = TextEditingController();
//   bool _isVerifyingOtp = false;
//   FocusNode _otpFocusNode = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     listenForCode(); // Start listening for OTP code
//   }
//
//   @override
//   void codeUpdated() {
//     setState(() {
//       _otpController.text = code ?? ''; // Auto-update OTP input field
//       debugPrint('Auto-filled OTP: $code');
//
//       // Automatically move the focus to the next input field if OTP is complete
//       if (code?.length == 4) {
//         FocusScope.of(context).requestFocus(FocusNode()); // Remove focus from the current OTP field
//         verifyOtp(); // Automatically verify once all digits are entered
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     SmsAutoFill().unregisterListener(); // Clean up the listener
//     _otpFocusNode.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }
//
//
//
//   Future<void> verifyOtp() async {
//     final otp = _otpController.text.trim();
//
//     // Validate OTP length
//     if (otp.isEmpty || otp.length != 4) {
//       _showErrorDialog('Please enter a valid OTP');
//       return;
//     }
//
//     final sentOtp = widget.sentOtp; // Server-sent OTP in response as a string
//
//     if (sentOtp == null || sentOtp.isEmpty) {
//       _showErrorDialog('Invalid OTP received from the server.');
//       return;
//     }
//
//     // Manually fix the invalid JSON format if necessary
//     String fixedResponse = sentOtp.replaceAllMapped(
//         RegExp(r'(\w+):'),
//             (match) => '"${match.group(1)}":');  // Add quotes around keys
//
//     // Parse the fixed JSON response
//     Map<String, dynamic> otpResponse;
//     try {
//       otpResponse = json.decode(fixedResponse); // Decode the fixed JSON
//     } catch (e) {
//       _showErrorDialog('Failed to parse OTP response: $e');
//       return;
//     }
//
//     final serverOtp = otpResponse['otp'].toString(); // Extract and convert OTP to string
//
//     // Debug: Print the OTPs being compared
//     debugPrint('Entered OTP: $otp');
//     debugPrint('Sent OTP: $serverOtp');
//
//     setState(() {
//       _isVerifyingOtp = true;
//     });
//
//     // Compare the entered OTP (string) with the server-sent OTP (converted to string)
//     if (otp == serverOtp) {
//       debugPrint('OTP Verified Successfully');
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('phoneNumber', widget.phone);
//     //  await prefs.setString('name', widget.name);
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomeScreen(
//            // name: widget.name,
//             phoneNumber: widget.phone,
//           ),
//         ),
//       );
//     } else {
//       _showErrorDialog('Invalid OTP. Please try again.');
//     }
//
//     setState(() {
//       _isVerifyingOtp = false;
//     });
//   }
//
//
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFE1F5FE),
//       appBar: AppBar(
//         backgroundColor: Color(0xFFE1F5FE),
//         title: SvgPicture.asset(
//           'assets/images/gg logo.svg',
//           width: 40,
//           height: 40,
//         ),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Enter OTP', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
//                 SizedBox(height: 20),
//                 PinFieldAutoFill(
//                   controller: _otpController,
//                   codeLength: 4, // Number of OTP digits
//                   focusNode: _otpFocusNode, // Assign the focus node to the field
//                   onCodeChanged: (code) {
//                     if (code?.trim().length == 4) {
//                       debugPrint('Entered OTP: ${code?.trim()}');
//                       verifyOtp();
//                     }
//                   },
//
//                   decoration: BoxLooseDecoration(
//                     strokeWidth: 1,
//                     gapSpace: 10,
//                     radius: Radius.circular(5),
//                     textStyle: TextStyle(fontSize: 20, color: Colors.black),
//                     bgColorBuilder: FixedColorBuilder(Colors.white), // Background color of each box
//                     strokeColorBuilder: FixedColorBuilder(Colors.black), // Border color of each box
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 16,
//             left: 16,
//             right: 16,
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF0FB7C6),
//                 ),
//                 onPressed: _isVerifyingOtp ? null : verifyOtp,
//                 child: _isVerifyingOtp
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text('Verify OTP', style: TextStyle(color: Colors.white)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
