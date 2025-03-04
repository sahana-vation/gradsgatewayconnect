// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import 'lead_model.dart';
//
// class LeadsScreen extends StatefulWidget {
//   @override
//   _LeadsScreenState createState() => _LeadsScreenState();
// }
//
// class _LeadsScreenState extends State<LeadsScreen> {
//   List<Lead> leads = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchLeads();
//   }
//
//   Future<void> fetchLeads() async {
//     final url = Uri.parse('https://portal.gradsgateway.com/api/get_leadsnew');
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Cookie': 'session_id=a5cd974103ca16ee6baee4625321665dadd1beae',
//       },
//       body: jsonEncode({
//         "mobile": 8618046831,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
//       final List<dynamic> data = jsonResponse['result']['data'];
//
//       setState(() {
//         leads = data.map((lead) => Lead.fromJson(lead)).toList();
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       throw Exception('Failed to load leads');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Leads')),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         itemCount: leads.length,
//         itemBuilder: (context, index) {
//           final lead = leads[index];
//           return Card(
//             child: ListTile(
//               title: Text(lead.name),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Phone: ${lead.phone}'),
//                   Text('Email: ${lead.email}'),
//                   Text('Status: ${lead.status}'),
//                   Text('Application: ${lead.applicationStatus}'),
//                   Text('Referrer: ${lead.referrerName}'),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:developer'; // For logging
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradsgatewayconnect/home.dart';

void showOtpBottomSheet(BuildContext context, String phone, String sentOtp) {
  bool _isVerifyingOtp = false;
  bool _isResendingOtp = false;
  List<TextEditingController> otpControllers =
  List.generate(4, (_) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(4, (_) => FocusNode());
  String currentOtp = sentOtp; // Store the latest OTP response

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          /// Function to Show Error Dialog
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

          /// Function to Verify OTP
          Future<void> verifyOtp() async {
            final otp = int.tryParse(
                otpControllers.map((controller) => controller.text).join().trim());

            if (otp == null || otp.toString().length != 4) {
              _showErrorDialog('Please enter a valid 4-digit OTP.');
              return;
            }

            if (currentOtp.isEmpty) {
              _showErrorDialog('Invalid OTP received from the server.');
              return;
            }

            // ✅ Fix JSON format
            String fixedJson = currentOtp.replaceAllMapped(
                RegExp(r'(\w+):'),
                    (match) => '"${match.group(1)}":' // Add quotes around JSON keys
            );

            debugPrint("Fixed OTP JSON: $fixedJson");

            // ✅ Now safely decode the fixed JSON
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
              await prefs.setString('phoneNumber', phone);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(phoneNumber: phone),
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

            final url = Uri.parse("https://portal.gradsgateway.com/api/signinnew?mobile=$phone");

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
                      "Sign in code has been sent to +91$phone,\ncheck your inbox to continue the sign process.",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: TextField(
                              controller: otpControllers[index],
                              focusNode: otpFocusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 3) {
                                  FocusScope.of(context)
                                      .requestFocus(otpFocusNodes[index + 1]);
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context)
                                      .requestFocus(otpFocusNodes[index - 1]);
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _isResendingOtp ? null : resendOtp,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Haven't received the sign code?",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _isResendingOtp ? " Resending..." : " Resend it.",
                            style: TextStyle(
                                color: Color(0xFF0FB7C6), fontWeight: FontWeight.bold),
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
        },
      );
    },
  );
}