import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

class NewFormScreen extends StatefulWidget {
  final String? name;
  final String phoneNumber;

  NewFormScreen({this.name, required this.phoneNumber});

  @override
  _NewFormScreenState createState() => _NewFormScreenState();
}

class _NewFormScreenState extends State<NewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool isOverseasAdmission = false;
  bool isEducationLoan = false;
  bool isLoading = false;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(seconds: 20), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have been inactive for more than 20 seconds')),
      );
      Navigator.pop(context);
    });
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final String apiUrl = "https://portal.gradsgateway.com/api/v1/leads";
      List<String> messages = [];
      if (isOverseasAdmission) messages.add('Looking for Overseas Admission');
      if (isEducationLoan) messages.add('Looking for Overseas Education Loan');

      final Map<String, String> params = {
        'StudentName': _nameController.text,
        'Email': _emailController.text,
        'MobileNumber': _phoneController.text,
        'Message': messages.join(', '),
        'ReferrerNumber': widget.phoneNumber,
        'Source': "MobileAPK",
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: params,
        );

        print("Response Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        final responseBody = json.decode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (responseBody is Map && responseBody.containsKey('Message')) {
            String message = responseBody['Message'];

            if (message == "Lead Generated Successfully !!") {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Success'),
                  content: Text('Your Application has been submitted successfully.'),
                  actions: [
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context).pop(); // Go back
                      },
                    ),
                  ],
                ),
              );
            } else {
              _showSnackBar(message); // Show error message from API response
            }
          } else {
            _showSnackBar('Unexpected server response');
          }
        } else {
          _showSnackBar('Failed to generate lead: ${response.body}');
        }
      } catch (e) {
        _showSnackBar('Error: $e');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }



  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetInactivityTimer,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            /// **Fixed Image & Texts**
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SvgPicture.asset(
                  'assets/images/Asset 1 3 (1).svg',
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        "Enter Student’s Details",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text("Fill up the form to submit your referral"),
                    ],
                  ),
                ),
              ],
            ),

            /// **Scrollable Form**
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        onChanged: (_) => _resetInactivityTimer(),
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Enter student name' : null,
                      ),
                      SizedBox(height: 20),

                      TextFormField(
                        maxLength: 10, // Limit input to 10 digits
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Allow only digits
                          LengthLimitingTextInputFormatter(10), // Limit input to 10 characters
                        ],
                        controller: _phoneController,
                        onChanged: (_) => _resetInactivityTimer(),
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(),
                          counterText: "",
                        ),


                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty ? 'Enter phone number' : null,

                      ),
                      SizedBox(height: 20),

                      TextFormField(


                        controller: _emailController,
                        onChanged: (_) => _resetInactivityTimer(),
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.contains('@') ? null : 'Enter valid email',
                      ),
                      SizedBox(height: 20),

                      Row(
                        children: [
                          Checkbox(
                            value: isOverseasAdmission,
                            onChanged: (value) => setState(() => isOverseasAdmission = value!),
                          ),
                          Text("For Overseas Admission"),
                        ],
                      ),

                      Row(
                        children: [
                          Checkbox(
                            value: isEducationLoan,
                            onChanged: (value) => setState(() => isEducationLoan = value!),
                          ),
                          Text("For Overseas Education Loan"),
                        ],
                      ),

                      SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0FB7C6),
                            minimumSize: Size(326, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: isLoading
                              ? Text("Submitting...", style: TextStyle(color: Colors.white))
                              : Text("Submit", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
