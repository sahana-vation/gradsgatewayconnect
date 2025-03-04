import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final String? name;
  final String? phone;
  final String? email;
  final String? status;
  final String? leadStatus;
  final List<String> applicationStatuses;

  ApplicationDetailsScreen({
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.leadStatus,
    required this.applicationStatuses,
  });

  @override
  Widget build(BuildContext context) {
    String singleApplicationStatus =
    applicationStatuses.isNotEmpty ? applicationStatuses.first : "No Status Available";

    return Scaffold(
      appBar: AppBar(
        title: Text("Application Details"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          /// Fixed Image at the Top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white, // Ensures background matches
              padding: EdgeInsets.all(16),
              child: SvgPicture.asset(
                'assets/images/Asset 1 2.svg',
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// Scrollable Content Below the Image
          Padding(
            padding: EdgeInsets.only(top: 220), // Creates space below the fixed image
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDetailField("Full Name", name ?? ""),
                  buildDetailField("Phone Number", phone ?? ""),
                  buildDetailField("Email", email ?? ""),
                  buildDetailFieldWithLink("Lead Status", status ?? ""),
                  buildDetailFieldWithLink("Application Status", singleApplicationStatus ?? ""),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          border: Border.all(color: Color(0xFFE6EBF2), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailFieldWithLink(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          border: Border.all(color: Color(0xFFE6EBF2), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
