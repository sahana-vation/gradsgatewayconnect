// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'otp_screen.dart';
//
// class PhoneAuthScreen extends StatefulWidget {
//   @override
//   _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
// }
//
// class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//
//   bool _isReturningUser = false;
//   bool _isLoading = true;
//   bool _isSendingCode = false;
//   bool _isSignUp = false;
//
//   String? sentOtp;
//
//   @override
//   void initState() {
//     super.initState();
//     _phoneController.text = '';
//     _checkUserSession();
//   }
//
//   void _checkUserSession() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedPhoneNumber = prefs.getString('phoneNumber');
//     String? storedName = prefs.getString('name');
//
//     if (storedPhoneNumber != null) {
//       setState(() {
//         _isReturningUser = true;
//         _phoneController.text = storedPhoneNumber;
//         _nameController.text = storedName ?? '';
//       });
//     }
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Future<void> sendVerificationCode() async {
//     String phone = _phoneController.text.trim();
//
//     if (phone.startsWith('+91')) {
//       phone = phone.substring(3);
//     }
//     if (phone.length > 10) {
//       phone = phone.substring(phone.length - 10);
//     }
//
//     if (phone.length < 10) {
//       _showErrorDialog('Please enter a valid phone number');
//       return;
//     }
//
//     setState(() {
//       _isSendingCode = true;
//     });
//
//     final url = Uri.parse("https://portal.gradsgateway.com/api/signin?mobile=$phone");
//
//     try {
//       final response = await http.post(url);
//       log("Response Code: ${response.statusCode}");
//       log("Response Body: ${response.body}");
//
//       final responseData = json.decode(response.body);
//
//       if (response.statusCode == 200) {
//         if (responseData["Message"] == "Please signup before signing in.") {
//           _showErrorDialog("Please sign up before signing in.");
//         } else {
//           sentOtp = responseData.toString();
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OtpScreen(
//                 phone: _phoneController.text,
//                 sentOtp: sentOtp,
//               ),
//             ),
//           );
//         }
//       } else {
//         _showErrorDialog('Failed to send OTP. Please try again.');
//       }
//     } catch (e) {
//       _showErrorDialog('Error sending OTP: $e');
//     } finally {
//       setState(() {
//         _isSendingCode = false;
//       });
//     }
//   }
//
//
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Alert Message'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
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
//     if (_isLoading) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
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
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Sign In',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
//               ),
//               SizedBox(height: 30),
//               TextFormField(
//                 maxLength: 12,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                 ],
//                 enabled: !_isReturningUser,
//                 controller: _phoneController,
//                 buildCounter: (BuildContext context,
//                     {int? currentLength, int? maxLength, bool? isFocused}) {
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Enter phone number',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//
//               SizedBox(height: 20),
//
//
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: !_isSendingCode ? sendVerificationCode : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF042628),
//                     padding: EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: _isSendingCode
//                       ? CircularProgressIndicator(color: Colors.white)
//                       : Text('Send OTP', style: TextStyle(fontSize: 16, color: Colors.white)),
//                 ),
//               ),
//               // SizedBox(
//               //   width: double.infinity,
//               //   child: ElevatedButton(
//               //     style: ElevatedButton.styleFrom(
//               //       backgroundColor: Color(0xFF0FB7C6),
//               //     ),
//               //     onPressed: !_isSendingCode ? sendVerificationCode : null,
//               //     child: _isSendingCode
//               //         ? CircularProgressIndicator()
//               //         : Text(
//               //       'Send OTP',
//               //       style: TextStyle(color: Colors.white),
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
