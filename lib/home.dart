import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradsgatewayconnect/privacy_policy_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'form_screen.dart';
import 'phone_auth_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final String? name;
  final String phoneNumber;

  HomeScreen({this.name, required this.phoneNumber});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Logout function
  Future<void> _logout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Logout"),
          ),
        ],
      ),
    );

    if (result == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PhoneAuthScreen()),
      );
    }
  }





  Future<void> _deleteAccount(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account"),
        content: Text("If you delete the account, all the data will be removed permanently."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete")),
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
          Uri.parse("https://portal.gradsgateway.com/api/deleteaccount?name=${widget.name}&mobile=${widget.phoneNumber}"),

        );

        if (!mounted) return; // Check widget context validity
        Navigator.pop(context); // Remove loading dialog

        if (response.statusCode == 200) {
          final responseData = response.body; // Treat as plain string
          print("Service Request Number: $responseData");
       //  final serviceRequestNumber = responseData["serviceRequestNumber"];
        //  final serviceRequestNumber = responseData["serviceRequestNumber"];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PhoneAuthScreen()));
      //    _showSuccessDialog(responseData["serviceRequestNumber"]);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "Account Deletion Initiated",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "We have received Service Request No ",
                    ),
                    TextSpan(
                      text: responseData.toString(), // Your dynamic service request number
                      style: TextStyle(fontWeight: FontWeight.bold), // Bold style for the number
                    ),
                    TextSpan(
                      text: " for your Account Deletion. Your account and all associated data will be removed in 7 working days. You can reach out to us at contact@gradsgateway.com for any additional information.",
                    ),
                  ],
                ),
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
          _showErrorDialog("Failed to delete account. Please try again.");

        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Remove loading dialog
        _showErrorDialog("Error deleting account: $e");
        print("$e");
      }
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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


  @override
  Widget build(BuildContext context) {
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF042628)),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.person,color: Colors.white,),
                    Text(
                      widget.name ?? "User",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Submit Referral"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormScreen(
                      phoneNumber: widget.phoneNumber,
                      name: widget.name,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () => _logout(context),
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text("Delete Account"),
              onTap: () => _deleteAccount(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height:10),
            Text(
              'Your Global Partner for Study Abroad Loans',
              style: TextStyle(
                fontSize: 15,
                color:  Color(0xFF042628).withOpacity(0.8),
                fontFamily: 'Poppins', // Use Poppins font family
              ),// Text color
            ),
            SizedBox(height:30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Image.asset(
                      'assets/icon/us-circle-01 1.png', // Path to your PNG image
                      width: 50, // Set the desired width
                      height: 50, // Set the desired height
                      fit: BoxFit.cover, // Control how the image should fit within the bounds
                    ),
                    SizedBox(height: 10,),
                    Text(
                      'USA',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color:  Color(0xFF000000),
                        fontFamily: 'Poppins', // Use Poppins font family
                      ),// Text color
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/icon/circle-flag-of-canada-free-png 1.png', // Path to your PNG image
                      width: 50, // Set the desired width
                      height: 50, // Set the desired height
                      fit: BoxFit.cover, // Control how the image should fit within the bounds
                    ),
                    SizedBox(height: 10,),
                    Text(
                      'CANNADA',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color:  Color(0xFF000000),
                        fontFamily: 'Poppins', // Use Poppins font family
                      ),// Text color
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/icon/Mask group.png', // Path to your PNG image
                      width: 50, // Set the desired width
                      height: 50, // Set the desired height
                      fit: BoxFit.cover, // Control how the image should fit within the bounds
                    ),
                    SizedBox(height: 10,),
                    Text(
                      'UK',
                      style: TextStyle(
                        fontSize: 15,
                        color:  Color(0xFF000000),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins', // Use Poppins font family
                      ),// Text color
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/icon/pngwing.com (70) 1.png', // Path to your PNG image
                      width: 50, // Set the desired width
                      height: 50, // Set the desired height
                      fit: BoxFit.cover, // Control how the image should fit within the bounds
                    ),
                    SizedBox(height: 10,),
                    Text(
                      'AUSTRAILA',
                      style: TextStyle(
                        fontSize: 15,
                        color:  Color(0xFF000000),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins', // Use Poppins font family
                      ),// Text color
                    ),
                  ],
                ),

              ],
            ),
            SizedBox(height: 20,),

            Center(
              child: Text(
                'Our services extend to students from \ndiverse countries and backgrounds.',
                style: TextStyle(
                  fontSize: 15,
                  color:  Color(0xFF000000)..withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins', // Use Poppins font family
                ),// Text color
              ),
            ),
            Image.asset(
              'assets/icon/pngwing.com (75) 1.png', // Path to your PNG image
              width: 375, // Set the desired width
              height: 226, // Set the desired height
              fit: BoxFit.cover, // Control how the image should fit within the bounds
            ),
            Container(
              color:  Color(0xFFE1F5FE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),
                  Text(
                    'Help your friends achieve their\n      study abroad dreams!',
                    style: TextStyle(
                      fontSize: 16,
                      color:  Color(0xFF000000).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins', // Use Poppins font family
                    ),// Text color
                  ),
                  SizedBox(height: 20,),
                  Text(
                    'Click Apply Now to refer a\n friend and earn rewards!!!',
                    style: TextStyle(
                      fontSize: 12,
                      color:  Color(0xFF000000)..withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins', // Use Poppins font family
                    ),// Text color

                  ),
                  SizedBox(height: 10,),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'You have agreed to our ',
                          style: TextStyle(
                            fontSize: 12,
                            color:  Color(0xFF000000)..withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins', // Use Poppins font family
                          ),// Text color
                        ),
                        Text(
                          'privacy policy.',
                          style: TextStyle(
                            fontSize: 12,
                            color:  Colors.blueAccent,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins', // Use Poppins font family
                          ),// Text color
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18,),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormScreen(
                                phoneNumber: widget.phoneNumber,
                                name: widget.name,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Color(0xFF042628), // Background color
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40), // Button size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                        ),
                        child: Text(
                          'Apply Now',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Poppins', // Use Poppins font family
                          ),// Text color
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                ],
              ),


            ),


          ],
        ),
      ),


    );
  }
}
