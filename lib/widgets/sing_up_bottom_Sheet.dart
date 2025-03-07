import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';
import 'package:gradsgatewayconnect/widgets/otp_bottom_sheet.dart';
import 'package:gradsgatewayconnect/widgets/sign_in_bottom_sheet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../privacy_policy_screen.dart';

void showSignUpBottomSheet(BuildContext parentContext) {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool isStudent = false;
  bool isChannelPartner = false;
  bool isPrivacyAccepted = false;
  String? roleError;
  String countryCode = '+91';
  bool isLoading = false;

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showAlreadySignedUpDialog() {
    showDialog(
      context: parentContext,
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

  Future<void> signUp() async {
    if (!isStudent && !isChannelPartner) {
      roleError = "Please select a role.";
      return;
    }

    String type = isStudent ? '1' : '0';
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('name', name);
    await prefs.setString('phone', phone);
    await prefs.setString('role', isStudent ? 'Student' : 'Channel Partner');

    if (email.isEmpty || name.isEmpty || phone.isEmpty) {
      _showAlertDialog('Error', 'Please fill in all the fields.');
      return;
    }

    String formattedPhone = phone.replaceAll(' ', '');
    String fullPhoneNumber = formattedPhone.length > 10
        ? formattedPhone.substring(formattedPhone.length - 10)
        : formattedPhone;

    String apiUrl = 'https://portal.gradsgateway.com/api/signupnew?mobile=$fullPhoneNumber&name=$name&email=$email&type=$type';

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      var response = await http.post(Uri.parse(apiUrl));
      Navigator.pop(parentContext);
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody["Message"] == "You are already signed up. Please sign in") {
          _showAlreadySignedUpDialog();
        } else {
          print("Signup Successful: $responseBody");
          String sentOtp = responseBody.toString();
          Navigator.pop(parentContext);
          showOtpBottomSheet(parentContext, phone, sentOtp);
        }
      } else {
        print("Signup Failed: ${response.body}");
        _showAlertDialog('Signup Failed', 'An error occurred while signing up. Please try again.');
      }
    } catch (e) {
      Navigator.pop(parentContext);
      print("Error: $e");
      _showAlertDialog('Error', 'An error occurred. Please check your network connection and try again.');
    }
  }

  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            Image.asset('assets/images/Group 11 (1).png', width: 54.83, height: 50.0),
                            SizedBox(height: 8),
                            Image.asset('assets/images/Grads Gateway.png', width: 215, height: 25),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Select your role below:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Checkbox(
                            value: isStudent,
                            onChanged: (value) {
                              setState(() {
                                isStudent = value ?? false;
                                isChannelPartner = !isStudent;
                                roleError = null;
                              });
                            },
                            activeColor: Color(0xFF0FB7C6),
                          ),
                          Text("Student"),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: isChannelPartner,
                            onChanged: (value) {
                              setState(() {
                                isChannelPartner = value ?? false;
                                isStudent = !isChannelPartner;
                                roleError = null;
                              });
                            },
                            activeColor: Color(0xFF0FB7C6),
                          ),
                          Text("Channel Partner"),
                        ],
                      ),

                      if (roleError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(roleError!, style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),

                      SizedBox(height: 20),
                      Text("Email"),
                      TextField(controller: emailController, decoration: InputDecoration(hintText: "My Email", border: OutlineInputBorder())),
                      SizedBox(height: 15),

                      Text("Name"),
                      TextField(controller: nameController, decoration: InputDecoration(hintText: "Name", border: OutlineInputBorder())),
                      SizedBox(height: 15),

                      Text("Phone Number"),
                      TextField(
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Phone number",
                          border: OutlineInputBorder(),
                          counterText: "",
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                      children: [
              Checkbox(
              value: isPrivacyAccepted,
              onChanged: (value) => setState(() => isPrivacyAccepted = value ?? false),
              activeColor: Color(0xFF0FB7C6),
              ),
              Expanded(
              child: GestureDetector( // Makes the text clickable
              onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()), // Replace with your actual screen
              );
              },
              child: Text(
              "I agree with privacy policy",
              style: TextStyle(
              decoration: TextDecoration.underline,
              color: Color(0xFF0FB7C6),
              ),
              ),
              ),
              ),
              ],
              ),

                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0FB7C6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
              onPressed: (isStudent || isChannelPartner) && isPrivacyAccepted
              ? () async {
              setState(() => isLoading = true);
              await signUp();
              setState(() => isLoading = false);
              }
                  : null,
              child: isLoading
              ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)// Show loader
                              : Text("Sign Up", style: TextStyle(color: Colors.white)),
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
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            showSignInBottomSheet(parentContext);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(color: Color(0xFF263238), fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " Sign In Here",
                                style: TextStyle(color: Color(0xFF0FB7C6), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

