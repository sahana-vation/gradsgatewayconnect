import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:gradsgatewayconnect/widgets/sing_up_bottom_Sheet.dart';
import 'package:http/http.dart' as http;

import 'otp_bottom_sheet.dart'; // Import OTP bottom sheet

void showSignInBottomSheet(BuildContext context) {
  TextEditingController phoneController = TextEditingController();
  bool isSendingCode = false; // Flag to track API call state
  bool isChecked = false; // Track Remember Me checkbox state

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Function to send OTP API request
          Future<void> sendVerificationCode() async {

            String phone = phoneController.text.trim();

            // Validate phone number
            if (phone.startsWith('+91')) {
              phone = phone.substring(3);
            }
            if (phone.length > 10) {
              phone = phone.substring(phone.length - 10);
            }
            if (phone.length < 10) {
              _showErrorDialog(context, 'Please enter a valid phone number');
              return;
            }

            setState(() {
              isSendingCode = true;
            });

            final url = Uri.parse("https://portal.gradsgateway.com/api/signinnew?mobile=$phone");

            try {
              final response = await http.post(url);

              // Print response status and body
              log("Response Code: ${response.statusCode}");
              log("Response Body: ${response.body}");

              final responseData = json.decode(response.body);

              if (response.statusCode == 200) {
                if (responseData["Message"] == "Please signup before signing in.") {
                  _showErrorDialog(context, "Please sign up before signing in.");
                } else {
                  String sentOtp = responseData.toString();
                  log("Received OTP Response: $sentOtp"); // Print OTP response
                  Navigator.pop(context); // Close sign-in bottom sheet
                  showOtpBottomSheet(context, phone, sentOtp);
                }
              } else {
                _showErrorDialog(context, 'Failed to send OTP. Please try again.');
              }
            } catch (e) {
              log("Error sending OTP: $e"); // Print error
              _showErrorDialog(context, 'Error sending OTP: $e');
            } finally {
              setState(() {
                isSendingCode = false;
              });
            }
          }


          return Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Center(
                  child: Text(
                    "Sign In",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    "Sign in to my account",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20),
                Text("Phone Number"),
                SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: CountryCodePicker(
                      onChanged: (code) {},
                      initialSelection: 'IN',
                      favorite: ['+91'],
                      showFlag: true,
                      showFlagMain: true,
                      showDropDownButton: false,
                      alignLeft: false,
                    ),
                    hintText: "000 0000 000",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: Color(0xFF0FB7C6),
                    ),
                    const Text("Remember Me"),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0FB7C6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:  !isSendingCode ? sendVerificationCode : null, // Disable if "Remember Me" is unchecked
                    child: isSendingCode
                        ? CircularProgressIndicator(color: Colors.white) // Show loader
                        : Text("Sign In", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showSignUpBottomSheet(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: Color(0xFF263238), fontWeight: FontWeight.bold),
                        ),
                        Text(
                          " Sign Up Here",
                          style: TextStyle(color: Color(0xFF0FB7C6), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}


// Function to show error dialog
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Error"),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Text("OK"),
        ),
      ],
    ),
  );
}
