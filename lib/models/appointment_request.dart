
enum AppointmentStatus { pending, approved, rejected }

enum AppointmentType { consultation, followUp, test, other }

class AppointmentRequest {
  String id;
  String username;
  String phoneNumber;
  DateTime date;
  String message;
  String appointmentType;
  AppointmentStatus status;
  DateTime createdAt;
  String hospitalId;
  String? clerkingSummary;
  String? systemsSummary;
  String? assessmentId;
  bool clerkingFinished;

  AppointmentRequest({
    this.id = '',
    required this.username,
    required this.phoneNumber,
    required this.date,
    required this.message,
    required this.appointmentType,
    required this.status,
    required this.createdAt,
    required this.hospitalId,
    this.clerkingSummary,
    this.systemsSummary,
    this.assessmentId,
    this.clerkingFinished = false,
  });

  factory AppointmentRequest.fromMap(Map<dynamic, dynamic> data) {
    return AppointmentRequest(
      id: data['id'] ?? '',
      username: data['username'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      date: DateTime.parse(data['date']),
      message: data['message'] ?? '',
      appointmentType: data['appointmentType'],
      status: _getAppointmentStatus(data['status']),
      createdAt: DateTime.parse(data['createdAt']),
      hospitalId: data['hospitalId'] ?? '',
      clerkingSummary: data['clerkingSummary'],
      systemsSummary: data['systemsSummary'],
      assessmentId: data['assessmentId'],
      clerkingFinished: data['clerkingFinished'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'phoneNumber': phoneNumber,
      'date': date.toIso8601String(),
      'message': message,
      'appointmentType': appointmentType,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
      'hospitalId': hospitalId,
      'clerkingSummary': clerkingSummary,
      'systemsSummary': systemsSummary,
      'assessmentId': assessmentId,
      'clerkingFinished': clerkingFinished,
    };
  }

  static AppointmentType _getAppointmentType(String? type) {
    switch (type) {
      case 'home':
        return AppointmentType.consultation;
      case 'follow-up':
        return AppointmentType.followUp;
      default:
        return AppointmentType.other;
    }
  }

  static AppointmentStatus _getAppointmentStatus(String? status) {
    switch (status) {
      case 'approved':
        return AppointmentStatus.approved;
      case 'rejected':
        return AppointmentStatus.rejected;
      default:
        return AppointmentStatus.pending;
    }
  }

  static String _appointmentTypeToString(AppointmentType type) {
    switch (type) {
      case AppointmentType.consultation:
        return 'consultation';
      case AppointmentType.followUp:
        return 'follow-up';
      case AppointmentType.test:
        return 'test';
      case AppointmentType.other:
        return 'other';
    }
  }

  static String _statusToString(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.approved:
        return 'approved';
      case AppointmentStatus.rejected:
        return 'rejected';
      case AppointmentStatus.pending:
        return 'pending';
    }
  }
}
