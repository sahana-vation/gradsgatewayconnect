import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'application_details_screen.dart'; // Import the details screen
import 'lead_model.dart';

class MyApplicationsScreen extends StatefulWidget {
  final String? phoneNumber;

  MyApplicationsScreen({required this.phoneNumber});

  @override
  _MyApplicationsScreenState createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  List<Lead> applications = [];
  bool isLoading = true;
  String message = ''; // To hold the message if no data is found

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    final url = Uri.parse('https://portal.gradsgateway.com/api/get_leadsnew');

    // Adding the headers to specify that we're sending JSON
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "mobile": widget.phoneNumber,
    });

    // Sending the request with headers and body
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final String responseMessage = jsonResponse['result']['Message'];
      final List<dynamic> data = jsonResponse['result']['data'] ?? [];

      if (data.isEmpty) {
        // No data found, set the message from the API response
        setState(() {
          message = responseMessage;
          isLoading = false;
        });
      } else {
        // Data found, map the data into applications
        setState(() {
          applications = data.map((lead) => Lead.fromJson(lead)).toList();
          message = responseMessage; // Optionally you can display a message like "Data Found"
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
        message = "Error: ${response.reasonPhrase}"; // Set the message from the response reason
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Applications"),
        elevation: 1,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [

          SvgPicture.asset(
            'assets/images/Asset 1 1.svg',
            width: MediaQuery.of(context).size.width,
            height: 200,
            fit: BoxFit.cover,
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : applications.isEmpty
                ? Center(
              child: Text(
                message.isNotEmpty ? message : 'No applications available.',
                textAlign: TextAlign.center,
              ),
            ) // Display the message when no data
                : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      applications[index].name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(applications[index].email),
                    trailing: Text(applications[index].status),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplicationDetailsScreen(
                            name: applications[index].name,
                            phone: applications[index].phone,
                            email: applications[index].email,
                            status: applications[index].status,
                            leadStatus: "",
                            applicationStatuses: applications[index].applicationStatuses,

                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}