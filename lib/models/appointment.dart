import 'package:pandahealthhospital/models/diagnostic_result.dart';

import 'diagnostic_test.dart'; // Import the DiagnosticTest class file

class Appointment {
  String id;
  bool? approved;
  DateTime startTime = DateTime.now();
  String centerId;
  String patientId;
  String referralId;
  String notes;
  List<DiagnosticTest> tests;
  List<DiagnosticResult> results;

  Appointment(
      {this.id = '',
      this.approved,
      required this.startTime,
      this.centerId = '',
      this.patientId = '',
      this.referralId = '',
      this.notes = '',
      this.tests = const [], // Initialize with an empty list
      this.results = const []});

  factory Appointment.fromMap(data) {
    return Appointment(
      id: data['id'] ?? '',
      approved: data['approved'],
      startTime: DateTime.parse(data['startTime']),
      centerId: data['centerId'] ?? '',
      patientId: data['patientId'] ?? '',
      referralId: data['referralId'] ?? '',
      notes: data['notes'] ?? '',
      tests: (data['tests'] as List<dynamic>?)
              ?.map((test) => DiagnosticTest.fromMap(test))
              .toList() ??
          [], // Convert each test from the map to DiagnosticTest
      results: (data['results'] as List<dynamic>?)
              ?.map((test) => DiagnosticResult.fromMap(test))
              .toList() ??
          [], // Convert each test from the map to DiagnosticTest
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'approved': approved,
      'startTime': startTime,
      'centerId': centerId,
      'patientId': patientId,
      'referralId': referralId,
      'notes': notes,
      'tests': tests
          .map((test) => test.toMap())
          .toList(), // Convert each test to map
    };
  }
}
