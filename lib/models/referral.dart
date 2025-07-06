import 'package:pandahealthhospital/models/diagnostic_test.dart';

class Referral {
  String id;
  String patientId;
  String doctorId;
  String appointmentId;
  String patientPhone;
  String patientEmail;
  String creationDate;
  List<DiagnosticTest> tests;

  Referral({
    this.id = '',
    this.patientId = '',
    this.doctorId = '',
    this.appointmentId = '',
    this.patientPhone = '',
    this.patientEmail = '',
    this.creationDate = '',
    this.tests = const [],
  });

  factory Referral.fromMap(data) {
    return Referral(
      id: data['id'] ?? '',
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      patientPhone: data['patientPhone'] ?? '',
      patientEmail: data['patientEmail'] ?? '',
      creationDate: data['creationDate'] ?? '',
      tests: (data['tests'] as List<dynamic>?)
              ?.map((test) => DiagnosticTest.fromMap(test))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentId': appointmentId,
      'patientPhone': patientPhone,
      'patientEmail': patientEmail,
      'creationDate': creationDate,
      'tests': tests.map((test) => test.toMap()).toList(),
    };
  }
}
