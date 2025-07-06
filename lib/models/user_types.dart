enum UserTypes {
  patient,
  doctor,
  center,
  admin,
  ai,
}

extension UserTypesExtension on UserTypes {
  String get value {
    switch (this) {
      case UserTypes.patient:
        return 'patient';
      case UserTypes.doctor:
        return 'doctor';
      case UserTypes.center:
        return 'center';
      case UserTypes.admin:
        return 'admin';
      case UserTypes.ai:
        return 'ai';
    }
  }
}