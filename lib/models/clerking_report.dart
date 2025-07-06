import 'package:pandahealthhospital/models/validator.dart';

class ClerkingReport {
  String id = "";
  String createdOn = "";
  String hospitalId = "";
  String? patientId;
  String aiAnalysis = "";
  String doctorsNotes = "";
  String passcode = "";
  List<dynamic> documents = [];
  List<dynamic> doctors = [];

  ClerkingReport({
    required this.id,
    required this.createdOn,
    required this.hospitalId,
    this.patientId,
    required this.aiAnalysis,
    required this.passcode,
    required this.doctorsNotes,
    required this.documents,
    this.doctors = const [],
  });

  ClerkingReport.fromMap(Map<dynamic, dynamic> data) {
    id = validValue(id, data['id']) ?? "";
    createdOn = validValue(createdOn, data['createdOn']) ?? "";
    hospitalId = validValue(hospitalId, data['hospitalId']) ?? "";
    patientId = validValue(patientId, data['patientId']);
    aiAnalysis = validValue(aiAnalysis, data['aiAnalysis']) ?? "";
    passcode = validValue(passcode, data['passcode']) ?? "";
    doctorsNotes = validValue(doctorsNotes, data['doctorsNotes']) ?? "";
    documents = data['documents'] ?? [];
    doctors = data['doctors'] ?? [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdOn': createdOn,
      'hospitalId': hospitalId,
      'patientId': patientId,
      'aiAnalysis': aiAnalysis,
      'doctorsNotes': doctorsNotes,
      'documents': documents,
      'doctors': doctors,
    };
  }
}
