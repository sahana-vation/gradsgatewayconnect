import 'dart:async';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'phone_auth_screen.dart'; // Import PhoneAuthScreen for navigation

class FormScreen extends StatefulWidget {
  final String? name;
  final String phoneNumber;

  FormScreen({this.name, required this.phoneNumber});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _candidateNameController = TextEditingController();
  final TextEditingController _candidatePhoneController = TextEditingController();
  final TextEditingController _candidateEmailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool isOverseasAdmissionChecked = false;
  bool isOverseasLoanChecked = false;
  bool isLoading = false; // For showing loading indicator
  Timer? _inactivityTimer;

  // Function to log the user out by clearing the session
  void _logoutAndNavigateToLogin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear stored data (name and phone number)

    // Navigate to PhoneAuthScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PhoneAuthScreen()),
    );
  }
  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }
  // Start a timer to detect inactivity after 20 seconds
  void _startInactivityTimer() {
    _inactivityTimer?.cancel(); // Cancel any previous timer
    _inactivityTimer = Timer(Duration(seconds: 20), () {
      // Show a message and navigate to HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have been inactive for more than 20 seconds')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(phoneNumber: widget.phoneNumber,name: widget.name,)), // Replace with your HomeScreen
      );
    });
  }

  // Reset the inactivity timer whenever user interacts with the form
  void _resetInactivityTimer() {
    _startInactivityTimer();
  }


  // Function to send the referral data to the API
  Future<void> _submitReferral() async {
    if (_formKey.currentState!.validate()) {
      // Show loading spinner
      setState(() {
        isLoading = true;
      });

      final String apiUrl = "https://portal.gradsgateway.com/api/v1/leads";

      // Prepare the message based on selected checkboxes
      List<String> messages = [];
      if (isOverseasAdmissionChecked) {
        messages.add('Looking for Overseas Admission');
      }
      if (isOverseasLoanChecked) {
        messages.add('Looking for Overseas Education Loan');
      }

      // Set the message
      _messageController.text = messages.join(', ');

      // Prepare the data to send
      final Map<String, String> params = {
        'StudentName': _candidateNameController.text,
        'Email': _candidateEmailController.text,
        'MobileNumber': _candidatePhoneController.text,
        'Message': _messageController.text,
        'ReferrerName': widget.name ?? 'Unknown',
        'ReferrerNumber': widget.phoneNumber,
        'Source': "MobileAPK",
      };

      try {
        // Send the POST request
        final response = await http.post(
          Uri.parse(apiUrl),
          body: params,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody = json.decode(response.body);

          if (responseBody['Message'] == "Lead Generated Successfully !!") {
            // Show success message in a dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Success'),
                  content: Text('Thank you for Reference Submission.'),
                  actions: [
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                );
              },
            );
            _clearFormFields();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unexpected response: ${responseBody['Message']}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate lead. Status code: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      } finally {
        // Hide loading spinner
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Clear form fields after submission
  void _clearFormFields() {
    _candidateNameController.clear();
    _candidatePhoneController.clear();
    _candidateEmailController.clear();
    _messageController.clear();
    isOverseasAdmissionChecked = false;
    isOverseasLoanChecked = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetInactivityTimer,
      child: Scaffold(
        backgroundColor:  Color(0xFFE1F5FE),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: SvgPicture.asset(
            'assets/icon/gg logo.svg',
            width: 32,
            height: 32,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Color(0xFF0FB7C6),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name != null && widget.name!.isNotEmpty
                                  ? '${widget.name}'
                                  : '',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFFFFFFFF).withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              '${widget.phoneNumber}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF000000).withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Enter Student’s Details:',
                    style: TextStyle(
                      fontSize: 23,
                      color: Color(0xFF000000).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Fill up below form to submit your referral',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF000000).withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 20),
                  // Referral form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _candidateNameController,
                          onChanged: (value) => _resetInactivityTimer(),
                          decoration: InputDecoration(
                            labelText: 'Student Name',
                            labelStyle: TextStyle(
                              fontSize: 15,
                              color: Color(0xFFBDBDBD),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the candidate\'s name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _candidatePhoneController,
                          onChanged: (value) => _resetInactivityTimer(),
                          decoration: InputDecoration(
                            labelText: 'Student Phone Number',
                            labelStyle: TextStyle(
                              fontSize: 15,
                              color: Color(0xFFBDBDBD),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the candidate\'s phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _candidateEmailController,
                          onChanged: (value) => _resetInactivityTimer(),
                          decoration: InputDecoration(
                            labelText: 'Student Email Address',
                            labelStyle: TextStyle(
                              fontSize: 15,
                              color: Color(0xFFBDBDBD),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'What is the student looking for?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF042628),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              CheckboxListTile(
                                title: Text(
                                  'Overseas Admission',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF000000),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                value: isOverseasAdmissionChecked,
                                onChanged: (newValue) {
                                  setState(() {
                                    isOverseasAdmissionChecked = newValue ?? false;
                                    _resetInactivityTimer();
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: Color(0xFF042628),
                              ),
                              CheckboxListTile(
                                title: Text(
                                  'Overseas Education Loan',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF000000),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                value: isOverseasLoanChecked,
                                onChanged: (newValue) {
                                  setState(() {
                                    isOverseasLoanChecked = newValue ?? false;
                                    _resetInactivityTimer();
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: Color(0xFF042628),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitReferral,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Color(0xFF042628),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                                : Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 55,
                  //   child: OutlinedButton(
                  //     onPressed: () => _logoutAndNavigateToLogin(context),
                  //     style: OutlinedButton.styleFrom(
                  //       backgroundColor: Colors.white,
                  //       side: BorderSide(color: Color(0xFF0FB7C6)),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.zero,
                  //       ),
                  //     ),
                  //     child: Text(
                  //       'Logout',
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         color: Color(0xFF0FB7C6),
                  //         fontFamily: 'Poppins',
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dispose TextEditingControllers to prevent memory leaks
  @override
  void dispose() {
    _candidateNameController.dispose();
    _candidatePhoneController.dispose();
    _candidateEmailController.dispose();
    _messageController.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }
}
