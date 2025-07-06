import 'package:flutter/foundation.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/hospital.dart';

enum StoreUserType { Hospital }

class UserStore extends ChangeNotifier {
  Doctor? doctor;
  Hospital? hospital;

  UserStore();

  initializeUser(Hospital hospitalData) {
    //User has signed in with an auth method
    hospital = hospitalData;

    notifyListeners();
  }

  initializeHospital(Hospital hospitalData) {
    //User has signed in with an auth method
    hospital = hospitalData;

    notifyListeners();
  }
}
