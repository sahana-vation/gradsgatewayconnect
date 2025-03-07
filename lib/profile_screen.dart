import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;

  ProfileScreen({required this.phoneNumber, required this.name});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  /// Fetch profile data from API
  Future<Map<String, dynamic>> _fetchProfileData() async {
    try {
      final response = await http.get(Uri.parse(
          "https://portal.gradsgateway.com/api/profile?mobile=${widget.phoneNumber}"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load profile data");
      }
    } catch (e) {
      throw Exception("Error fetching profile data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            /// Background Image
            Positioned(
              top: 0,
              child: Image.asset(
                'assets/images/pexels-artyusufpatel-11458867 1.png',
                width: MediaQuery.of(context).size.width,
                height: 235,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20,),
            /// Fixed Profile Avatar
            Positioned(
              top: 180, // Adjust as needed
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/icon 512.png'),
                radius: 45,
              ),
            ),
            Positioned(
              top: 280,
              child: SvgPicture.asset(
                'assets/images/Frame 1628.svg',
                width: 260,
              ),
            ),

            /// Main Content (Fixed, No Scroll)
            Center(
              child: SizedBox(
                width: 375,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Keeps content centered
                    children: [
                      SizedBox(height: 310,),

                      /// Fetch and Display User Details
                      FutureBuilder<Map<String, dynamic>>(
                        future: _fetchProfileData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildShimmerLoading();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (!snapshot.hasData) {
                            return Text("No profile data found");
                          }

                          final data = snapshot.data!;
                          return Column(
                            children: [
                              _buildInputField("Full Name", data['Name'] ?? "N/A"),
                              _buildInputField("Email", data['Email'] ?? "N/A"),
                              _buildInputField("Phone Number", widget.phoneNumber),
                              _buildInputField("Role", data['type'] ?? "N/A"),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 10),

                      /// Custom Logout & Delete Widgets
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DeleteAccountWidget(onDelete: () => _deleteAccount(context)),
                          SizedBox(width: 6),
                          LogoutWidget(onLogout: () => _logout(context)),
                        ],
                      ),

                      SizedBox(height: 20),
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


  /// Widget for input fields
  Widget _buildInputField(String label, String value) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 50, maxHeight: 60), // ✅ Auto height
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE6EBF2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ Prevent extra height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  /// Shimmer Effect for Loading
  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(4, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 326,
            height: 68,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFE6EBF2)),
            ),
          ),
        );
      }),
    );
  }

  /// Logout Function
  void _logout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              // Clear SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Navigate to SplashScreen and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SplashScreen()),
                    (route) => false, // Removes all previous routes
              );
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );

    if (result == true) {
      print("User logged out successfully.");
    }
  }


  /// Delete Account Function

  Future<void> _deleteAccount(BuildContext context) async {

    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Delete Account"),
            content: Text(
                "If you delete the account, all the data will be removed permanently."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(context, true),
                  child: Text("Delete")),
            ],
          ),
    );

    if (result == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      try {
        final response = await http.post(
          Uri.parse(
              "https://portal.gradsgateway.com/api/deleteaccountnew?mobile=${widget.phoneNumber}&name=${widget.name}}"),
        );
        print("Deleting account for Phone: ${widget.phoneNumber}, Name: ${widget.name}");

        Navigator.pop(context); // Remove loading dialog

        if (response.statusCode == 200) {
          final responseData = jsonDecode(
              response.body); // Decode the response body into JSON

          // Extract the "Message" from the response
          final message = responseData["message"] ?? responseData["Message"] ?? "No message provided";
          print("Account Deletion Message: $message");

          // Clear preferences and navigate to PhoneAuthScreen
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => SplashScreen()));

          // Display confirmation dialog
          showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: Text(
                    "Account Deletion Initiated",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    message, // Display the actual message content
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"),
                    ),
                  ],
                ),
          );
        } else {
          _showErrorDialog(
              context, "Failed to delete account. Please try again.");
        }
      } catch (e) {
        Navigator.pop(context); // Remove loading dialog
        _showErrorDialog(context, "Error deleting account: $e");
        print("Error: $e");
      }
    }
  }

  /// Error Dialog Function
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Error"),
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
}

class DeleteAccountWidget extends StatelessWidget {
  final VoidCallback onDelete;

  DeleteAccountWidget({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDelete,
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 5),
            Text("Delete", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class LogoutWidget extends StatelessWidget {
  final VoidCallback onLogout;

  LogoutWidget({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLogout,
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.blue),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.blue),
            SizedBox(width: 5),
            Text("Logout", style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
