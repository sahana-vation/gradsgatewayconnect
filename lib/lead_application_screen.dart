// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:gradsgatewayconnect/lead_application_screen.dart';
// import 'package:gradsgatewayconnect/lead_model.dart';
// import 'package:http/http.dart' as http;
//
// class LeadAndApplicationScreen extends StatefulWidget {
//   final String phoneNumber;
//   LeadAndApplicationScreen({super.key, required this.phoneNumber});
//
//   @override
//   _LeadAndApplicationScreenState createState() =>
//       _LeadAndApplicationScreenState();
// }
//
// class _LeadAndApplicationScreenState extends State<LeadAndApplicationScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   Future<List<LeadModel>>? _futureLeads;
//   Future<ApplicationStatus>? _futureApplicationStatus;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _futureLeads = fetchLeads();
//     _futureApplicationStatus = fetchApplicationStatus();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   Future<List<LeadModel>> fetchLeads() async {
//     const url = 'https://portal.gradsgateway.com/api/get_leads';
//     final headers = {'Content-Type': 'application/json'};
//     final body = jsonEncode({"mobile": widget.phoneNumber});
//
//     final response = await http.post(Uri.parse(url), headers: headers, body: body);
//
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//
//       // Check for 'result'
//       final result = jsonData['result'];
//       if (result != null) {
//         // Check for 'Message' and handle it
//         if (result['Message'] != null) {
//           print('Message: ${result['Message']}');
//
//           // If "Leads Found" message exists, return the data
//           if (result['Message'] == "Leads Found") {
//             if (result['data'] is List) {
//               final List<dynamic> leadsData = result['data'];
//               return leadsData.map((item) => LeadModel.fromJson(item)).toList();
//             }
//           }
//
//           // Handle other messages (e.g., "No Leads Found")
//           return Future.error(result['Message']);
//         }
//
//         // Default fallback if 'Message' or 'data' is missing
//         return Future.error('Unexpected response format.');
//       }
//
//       // If 'result' is missing or not structured correctly
//       return Future.error('No result data found.');
//     } else {
//       return Future.error('Failed to load leads. Status code: ${response.statusCode}');
//     }
//   }
//
//
//
//   Future<ApplicationStatus> fetchApplicationStatus() async {
//     const url = 'https://portal.gradsgateway.com/api/get_leadsnew';
//     final headers = {'Content-Type': 'application/json'};
//     final body = jsonEncode({"mobile": widget.phoneNumber});
//
//     print("🚀 Sending API Request:");
//     print("URL: $url");
//     print("Headers: $headers");
//     print("Body: $body");
//     final response = await http.post(Uri.parse(url), headers: headers, body: body);
//
//     print("✅ Response Status Code: ${response.statusCode}");
//     print("📩 Response Body: ${response.body}");
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//
//       if (jsonData['result'] != null) {
//         final result = jsonData['result'];
//
//         if (result['loan_data'] is List) {
//           var loanDataList = result['loan_data'] as List;
//
//           // Ensure proper JSON parsing
//           List<LoanData> loanData = loanDataList
//               .map((i) => LoanData.fromJson(i as Map<String, dynamic>))
//               .toList();
//
//           return ApplicationStatus(loanData: loanData);
//         }
//
//         // Check if `Message` exists instead of `loan_data`
//         else if (result['Message'] != null) {
//           return ApplicationStatus(
//             loanData: [],
//             errorMessage: result['Message'],
//           );
//         }
//       }
//       return ApplicationStatus(
//         loanData: [],
//         errorMessage: 'No loan data found.',
//       );
//     } else {
//       return ApplicationStatus(
//         loanData: [],
//         errorMessage: 'Failed to load data. Status code: ${response.statusCode}',
//       );
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFE1F5FE),
//       appBar: AppBar(
//         backgroundColor: Color(0xFFE1F5FE),
//         title: const Text('My Applications'),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // Display Leads
//           FutureBuilder<List<LeadModel>>(
//             future: _futureLeads,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('${snapshot.error}'));
//               } else if (snapshot.hasData) {
//                 final leads = snapshot.data!;
//                 // Check if the leads list is empty and show a custom message from the API
//                 if (leads.isEmpty) {
//                   return FutureBuilder<ApplicationStatus>(
//                     future: _futureApplicationStatus,
//                     builder: (context, statusSnapshot) {
//                       // If application status is loaded, show the error message if it exists
//                       if (statusSnapshot.hasData && statusSnapshot.data!.errorMessage != null) {
//                         return Center(child: Text(statusSnapshot.data!.errorMessage!));
//                       }
//                       // Fallback message in case no application status is available
//                       return const Center(child: Text('No leads found '));
//                     },
//                   );
//                 }
//
//                 return ListView.builder(
//                   itemCount: leads.length,
//                   itemBuilder: (context, index) {
//                     final lead = leads[index];
//                     return LeadCard(lead: lead, isExpanded: true); // Always expanded
//                   },
//                 );
//               } else {
//                 return const Center(child: Text('No leads found'));
//               }
//             },
//           ),
//
//           // Display Application Status
//           FutureBuilder<ApplicationStatus>(
//             future: _futureApplicationStatus,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               } else if (!snapshot.hasData) {
//                 return const Center(child: Text('No application status found'));
//               }
//               else {
//                 final applicationStatus = snapshot.data!;
//
//                 // Check for error message and display it if present
//                 if (applicationStatus.errorMessage != null) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center, // Center vertically
//                       crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
//                       children: [
//                         Text(
//                           applicationStatus.errorMessage!,
//                           textAlign: TextAlign.center, // Ensure the text is centered within the widget
//                           style: TextStyle(fontSize: 16), // Optional: Adjust text size for readability
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 // If loan data is available, display it
//                 if (applicationStatus.loanData.isEmpty) {
//                   return const Center(child: Text('No application status found'));
//                 } else {
//                   final statuses = applicationStatus.loanData;
//                   return ListView.builder(
//                     itemCount: statuses.length,
//                     itemBuilder: (context, index) {
//                       final status = statuses[index];
//                       return ApplicationStatusCard(status: status,index: index,isExpanded: true);
//                     },
//                   );
//                 }
//               }
//             },
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomAppBar(
//         child: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(icon: Icon(Icons.account_box), text: 'Referrals'),
//             Tab(icon: Icon(Icons.assignment), text: 'Application Status'),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class LeadCard extends StatefulWidget {
//   final LeadModel lead;
//   final bool isExpanded;
//
//   const LeadCard({super.key, required this.lead, this.isExpanded = false});
//
//   @override
//   _LeadCardState createState() => _LeadCardState();
// }
//
// class _LeadCardState extends State<LeadCard> {
//   bool _isExpanded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _isExpanded = widget.isExpanded; // Initialize with widget value
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ExpansionTile(
//           title: Text(
//             widget.lead.name[0].toUpperCase()+ widget.lead.name.substring(1),
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           initiallyExpanded: _isExpanded,
//           onExpansionChanged: (bool expanding) {
//             setState(() {
//               _isExpanded = expanding;
//             });
//           },
//           children: [
//             // Pass an index here, e.g., 0, 1, 2, etc.
//             _buildTextRow('Student Name:', widget.lead.name[0].toUpperCase() +widget.lead.name.substring(1), 0),
//             _buildTextRow('Student Phone:', widget.lead.phone, 1),
//             _buildTextRow('Student Email:', widget.lead.email[0].toUpperCase() +widget.lead.email.substring(1), 2),
//
//             // _buildTextRow('Source:', widget.lead.source, 3),
//             _buildTextRow('Status:', widget.lead.status, 3),
//             _buildTextRow(
//                 'Date Submitted:', widget.lead.formattedDateStored, 4),
//             // _buildTextRow('Message:', widget.lead.message, 7),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildTextRow(String label, String value, int index) {
//     // Alternate row color between light blue and blue
//     Color rowColor = index % 2 == 0 ? Color(0xFFE1F5FE) : Color(0xFFE1F5FE);
//
//     return Padding(
//       padding: const EdgeInsets.only(top: 8.0), // Increased padding for more space
//       child: Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12), // Rounded corners
//         ),
//         color: rowColor, // Set the background color
//         elevation: 4, // Optional: Add a slight shadow for better visibility
//         child: Padding(
//           padding: const EdgeInsets.all(12.0), // Padding inside the card
//           child: Row(
//             children: [
//               Text(
//                 '$label ',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   value,
//                   style: TextStyle(color: Colors.black, fontSize: 14),
//                   softWrap: true,
//                   maxLines: 4,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }
//
// class ApplicationStatusCard extends StatefulWidget {
//   final LoanData status;
//   final int index;
//   final bool isExpanded;
//
//
//   const ApplicationStatusCard({super.key, required this.status, required this.index,this.isExpanded = false});
//
//   @override
//   State<ApplicationStatusCard> createState() => _ApplicationStatusCardState();
// }
//
// class _ApplicationStatusCardState extends State<ApplicationStatusCard> {
//   bool _isExpanded = false;
//   @override
//   void initState() {
//     super.initState();
//     _isExpanded = widget.isExpanded; // Initialize with widget value
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 5,
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: ExpansionTile(
//         initiallyExpanded: _isExpanded,
//         onExpansionChanged: (bool expanding) {
//           setState(() {
//             _isExpanded = expanding;
//           });
//         },
//         title: Text(
//           widget.status.name[0].toUpperCase() + widget.status.name.substring(1),
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//
//               children: [
//                 _buildTextRow('Application No:', widget.status.applicationNo, 1),
//                 _buildTextRow('Student Email:', widget.status.emailId[0].toUpperCase()+ widget.status.emailId.substring(1), 2),
//                 _buildTextRow('Student Mobile:', widget.status.mobileNo, 3),
//                 const SizedBox(height: 8),
//                 _buildTextRow('Status:', widget.status.status.toUpperCase(), 4),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//
//   }
//
//   // Define the _buildTextRow method inside the ApplicationStatusCard class
//   Widget _buildTextRow(String label, String value, int index) {
//     // Alternate row color between light blue and blue
//     Color rowColor = index % 2 == 0 ? Color(0xFFE1F5FE) : Color(0xFFE1F5FE);
//
//     return Padding(
//       padding: const EdgeInsets.only(top: 8.0), // Increased padding for more space
//       child: Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12), // Rounded corners
//         ),
//         color: rowColor, // Set the background color
//         elevation: 4, // Optional: Add a slight shadow for better visibility
//         child: Padding(
//           padding: const EdgeInsets.all(12.0), // Padding inside the card
//           child: Row(
//             children: [
//               Text(
//                 '$label ',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   value,
//                   style: TextStyle(color: Colors.black, fontSize: 14),
//                   softWrap: true,
//                   maxLines: 4,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
