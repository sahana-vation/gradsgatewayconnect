import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';  // Make sure to import the intl package

class LeadModel {
  final String name;
  final String phone;
  final String email;
  final String status;
  final String message;
  final String source;
  final DateTime dateStored;
  final String referrerName;
  final String referrerNumber;


  LeadModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.message,
    required this.source,
    required this.dateStored,
    required this.referrerName,
    required this.referrerNumber,
  });

  // Method to format date into the desired format
  String get formattedDateStored {
    final DateFormat formatter = DateFormat('dd MMM yyyy HH:mm:ss'); // Format: Day Month Year Hour:Minute:Second
    return formatter.format(dateStored);
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      source: json['source'] ?? '',
      dateStored: json['date_stored'] != null
          ? DateTime.parse(json['date_stored'])
          : DateTime.now(),
      referrerName: json['referrer_name'] ?? '',
      referrerNumber: json['referrer_number'] ?? '',
    );
  }
}

class ApplicationStatus {
  List<LoanData> loanData;
  final String? errorMessage;

  ApplicationStatus({required this.loanData, this.errorMessage});

  factory ApplicationStatus.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      // If loan_data is a list
      if (json['result']['loan_data'] is List) {
        var loanDataList = json['result']['loan_data'] as List;
        List<LoanData> loanData = loanDataList.map((i) => LoanData.fromJson(i)).toList();
        return ApplicationStatus(
          loanData: loanData,
        );
      }
      // If loan_data is a string
      else if (json['result']['loan_data'] is String) {
        // If loan_data is a string (error message)
        return ApplicationStatus(
          loanData: [],
          errorMessage: json['result']['loan_data'],  // Store the message as errorMessage
        );
      } else {
        throw Exception('Unexpected loan_data type');
      }
    } else {
      throw Exception('Unexpected JSON structure: Missing "result"');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['loan_data'] = this.loanData.map((e) => e.toJson()).toList();
    return data;
  }
}

class LoanData {
  String applicationNo;
  String name;
  String emailId;
  String mobileNo;
  String status;

  LoanData({
    required this.applicationNo,
    required this.name,
    required this.emailId,
    required this.mobileNo,
    required this.status,
  });

  factory LoanData.fromJson(Map<String, dynamic> json) {
    return LoanData(
      applicationNo: json['application no.'] ?? 'Unknown',
      name: json['name'] ?? 'No Name',
      emailId: json['email_id'] ?? 'No Email',
      mobileNo: json['mobile_no'] ?? 'No Mobile',
      status: json['status'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application no.': this.applicationNo,
      'name': this.name,
      'email_id': this.emailId,
      'mobile_no': this.mobileNo,
      'status': this.status,
    };
  }
}



