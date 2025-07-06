import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pandahealthhospital/models/app_notification.dart';
import 'package:pandahealthhospital/models/appointment.dart';
import 'package:pandahealthhospital/models/appointment_request.dart';
import 'package:pandahealthhospital/models/chat.dart';
import 'package:pandahealthhospital/models/chat_message.dart';
import 'package:pandahealthhospital/models/clerking_report.dart';
import 'package:pandahealthhospital/models/diagnostic_center.dart';
import 'package:pandahealthhospital/models/diagnostic_test.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/hmo.dart';
import 'package:pandahealthhospital/models/hospital.dart';
import 'package:pandahealthhospital/models/patient.dart';
import 'package:pandahealthhospital/models/referral.dart';
import 'package:pandahealthhospital/models/request_status.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Add stream subscription to monitor auth state changes
  StreamSubscription<User?>? _authStateSubscription;
  Timer? _tokenRefreshTimer;

  static const String chatsCollectionName = "Chats";

  // Initialize auth state listener
  void initAuthStateListener() {
    // Cancel existing subscription if any
    disposeAuthListener();

    // Listen to auth state changes
    _authStateSubscription =
        firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in, set up token refresh
        _setupTokenRefresh(user);
      } else {
        // User is signed out, cancel token refresh
        _tokenRefreshTimer?.cancel();
      }
    });
  }

  // Set up token refresh to prevent unexpected logouts
  void _setupTokenRefresh(User user) {
    // Cancel existing timer if any
    _tokenRefreshTimer?.cancel();

    // Set up timer to refresh token every 50 minutes (tokens expire after 1 hour)
    _tokenRefreshTimer =
        Timer.periodic(const Duration(minutes: 50), (timer) async {
      try {
        // Force token refresh
        await user.getIdToken(true);
        print('Firebase token refreshed successfully');
      } catch (e) {
        print('Error refreshing Firebase token: $e');
      }
    });
  }

  // Clean up resources
  void disposeAuthListener() {
    _authStateSubscription?.cancel();
    _tokenRefreshTimer?.cancel();
    _authStateSubscription = null;
    _tokenRefreshTimer = null;
  }

  Future checkIfHospitalSignedIn(BuildContext context) async {
    try {
      var user = await firebaseAuth.authStateChanges().first;
      if (user == null) return false;

      // showCustomToast("Attempting to get hospital");

      // Force reload user to ensure we have latest token/state
      await user.reload();
      // Get user again in case reload caused changes
      user = firebaseAuth.currentUser;

      if (user == null) return false;

      print(user.uid);
      Hospital? hospital = await getHospitalFromId(user.uid);

      subscribeToUserTopics(user.uid);

      print("This is the hospital gotten");
      print(hospital);
      if (hospital != null) {
        Provider.of<UserStore>(context, listen: false)
            .initializeHospital(hospital);
        return true;
      } else {
        return false;
      }
    } catch (er) {
      print(er);
      return false;
    }
  }

  Future reloadUserData(BuildContext context, String userId) async {
    Hospital? hospital = await getHospitalFromId(userId);

    print("This is the patient gotten");
    print(hospital);
    if (hospital != null) {
      Provider.of<UserStore>(context, listen: false).initializeUser(hospital);
      return true;
    } else {
      return false;
    }
  }

  Future resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (er) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      var user = await firebaseAuth.authStateChanges().first;
      await firebaseAuth.signOut();
      unsubscribeFromUserTopics(user?.uid ?? "");
      return true;
    } catch (er) {
      print(er);
      return false;
    }
  }

  Future<bool> deleteAccount(String userId) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('authDeleteUser');
      HttpsCallableResult<dynamic> response = await getDoc({'userId': userId});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error getting doctor $e");
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      var res = await checkIfHospitalSignedIn(context);
      if (res) {
        return true;
      } else {
        return false;
      }
    } catch (er) {
      print(er);
      return false;
    }
  }

  Future<bool> signInWithEmailAndPasswordAsHospital(
      BuildContext context, String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      var res = await checkIfHospitalSignedIn(context);
      if (res) {
        return true;
      } else {
        return false;
      }
    } catch (er) {
      print(er);
      return false;
    }
  }

  Future<bool> verifyPhoneAuthCode(
      BuildContext context, String verificationId, String smsCode) async {
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      // Sign the user in (or link) with the credential
      var user = await firebaseAuth.signInWithCredential(credential);

      if (user.user != null) {
        await reloadUserData(context, user.user!.uid);
        return true;
      } else {
        return false;
      }
    } catch (er) {
      print(er);
      return false;
    }
  }

  //This can return multiple tings
  //If returns true. No need to verify the phone number
  //If false the phone number could not be verified. So can't proceed
  //If string that is the verification code
  Future<Object> signInWithPhoneNumber(
      BuildContext context, String phoneNumber) async {
    try {
      final Completer<Object> completer = Completer<Object>();

      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await firebaseAuth.signInWithCredential(credential);
          await checkIfHospitalSignedIn(context);
          print("Verification Complete");
          completer.complete(true);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("This is the error code");
          print(e);
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
            showCustomErrorToast("Invalid Phone Number");
          }
          completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          completer.complete(false);
        },
      );

      return completer.future;
    } catch (er) {
      print(er);
      return false;
    }
  }

  Future<Doctor?> getDoctorFromId(String userId) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getDoctorFromUid');
      HttpsCallableResult<dynamic> response = await getDoc({'uid': userId});

      Map<dynamic, dynamic> responseData = response.data;

      if (responseData['status'] == 'success') {
        var doc = Doctor.fromMap(responseData['data']);

        return doc;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting doctor $e");
      return null;
    }
  }

  Future<Hospital?> getHospitalFromId(String userId) async {
    try {
      HttpsCallable getHos =
          FirebaseFunctions.instance.httpsCallable('getHospitalFromId');
      HttpsCallableResult<dynamic> response =
          await getHos({'hospitalId': userId});

      Map<dynamic, dynamic> responseData = response.data;
      print(response.data);

      if (responseData['status'] == 'success') {
        print(responseData['data'].runtimeType);
        var doc =
            Hospital.fromMap(responseData['data'] as Map<dynamic, dynamic>);

        return doc;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting hospital $e");
      return null;
    }
  }

  Future<ClerkingReport?> getClerkingReportFromId(String reportId) async {
    try {
      HttpsCallable getHos =
          FirebaseFunctions.instance.httpsCallable('getClerkingReportFromId');
      HttpsCallableResult<dynamic> response = await getHos({'id': reportId});

      Map<dynamic, dynamic> responseData = response.data;
      print(response.data);

      if (responseData['status'] == 'success') {
        print(responseData['data'].runtimeType);
        var doc = ClerkingReport.fromMap(
            responseData['data'] as Map<dynamic, dynamic>);

        return doc;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting hospital $e");
      return null;
    }
  }

  Future<Chat?> getChatFromId(List<String> ids, List<String> types) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getChatFromIds');
      HttpsCallableResult<dynamic> response =
          await getDoc({'ids': ids, 'types': types});

      Map<String, dynamic> responseData = response.data;
      print(response);

      if (responseData['status'] == 'success') {
        var doc = Chat.fromMap(responseData['data']);

        return doc;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting chat $e");
      return null;
    }
  }

  Future<List<Referral>> getMyReferrals(
      String doctorId, Referral? lastReferral) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getDoctorReferrals');
      HttpsCallableResult<dynamic> response =
          await getDoc({'doctorId': doctorId, 'lastReferral': lastReferral});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == 'success') {
        return ((responseData['data'] ?? []) as List)
            .map((e) => Referral.fromMap(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return [];
    }
  }

  Future<List<ClerkingReport>> getHospitalsClerkingReports(
      String hospitalId, ClerkingReport? lastReport) async {
    try {
      print("Getting reports");
      HttpsCallable getDoc = FirebaseFunctions.instance
          .httpsCallable('getHospitalClerkingReports');
      HttpsCallableResult<dynamic> response =
          await getDoc({'hospitalId': hospitalId, 'lastReport': lastReport});

      Map<String, dynamic> responseData = response.data;

      print("Reached here");
      print(responseData);

      if (responseData['status'] == 'success') {
        return ((responseData['data'] ?? []) as List)
            .map((e) => ClerkingReport.fromMap(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return [];
    }
  }

  Future<List<Referral>> getHospitalsReferrals(
      String hospitalId, Referral? lastReferral) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getHospitalReferrals');
      HttpsCallableResult<dynamic> response = await getDoc(
          {'hospitalId': hospitalId, 'lastReferral': lastReferral});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == 'success') {
        return ((responseData['data'] ?? []) as List)
            .map((e) => Referral.fromMap(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return [];
    }
  }

  Future<List<Hmo>> getHmos() async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getHmos');
      HttpsCallableResult<dynamic> response = await getDoc({});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == 'success') {
        return ((responseData['data'] ?? []) as List)
            .map((e) => Hmo.fromMap(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return [];
    }
  }

  Future<List<AppNotification>> getMyNotifications(
      String hospitalId, Notification? lastNotification) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getHospitalsNotifications');
      HttpsCallableResult<dynamic> response = await getDoc(
          {'hospitalId': hospitalId, 'lastNotification': lastNotification});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == 'success') {
        return ((responseData['data'] ?? []) as List)
            .map((e) => AppNotification.fromMap(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting notifications $e");
      return [];
    }
  }

  Future<bool> createReferral(Referral referral) async {
    try {
      // Initialize Cloud Functions
      final HttpsCallable createRef =
          FirebaseFunctions.instance.httpsCallable('createReferral');

      // Call the Cloud Function
      final response = await createRef.call(referral.toMap());

      // Extract response data
      final responseData = response.data as Map<String, dynamic>;

      print("Look here");
      print(responseData);
      print(TransactionStatus.success);

      // Check the status of the response
      if (responseData['status'] == 'success') {
        return responseData['data'] as bool;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String?> createClerkingReport(
      String hospitalId,
      String aiNotesText,
      String clerkingDetails,
      List<String>? documents,
      int formCompletionTime,
      String? patientPhoneNumber,
      String? appointmentId) async {
    try {
      // Initialize Cloud Functions
      final HttpsCallable createRef =
          FirebaseFunctions.instance.httpsCallable('createClerkingReport');

      // Call the Cloud Function
      final response = await createRef.call({
        'hospitalId': hospitalId,
        'aiAnalysis': aiNotesText,
        'documents': documents ?? [],
        'formCompletionTime': formCompletionTime,
        'patientPhone': patientPhoneNumber,
        'appointmentId': appointmentId,
      });

      // Extract response data
      final responseData = response.data as Map<String, dynamic>;

      print("Look here");
      print(responseData);
      print(TransactionStatus.success);

      // Check the status of the response
      if (responseData['status'] == 'success') {
        return responseData['data'] as String;
      } else {
        return "";
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<DiagnosticTest>> getTestsFromQuery(
      double lat, double lng, String query) async {
    try {
      final HttpsCallable getChats = FirebaseFunctions.instance
          .httpsCallable('searchForCentersThatOfferTestInLocation');
      final HttpsCallableResult response = await getChats.call({
        'lat': lat,
        'lng': lng,
        'testQuery': query,
      });

      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;

      print("Tests Response");
      print(responseData);

      if (responseData['status'] == 'success') {
        return List.from(responseData['data'])
            .map((e) => DiagnosticTest.fromMap(e))
            .toList();
      } else {
        return <DiagnosticTest>[];
      }
    } catch (e) {
      print("Error getting tests: $e");
      return <DiagnosticTest>[];
    }
  }

  Future<List<Appointment>> getMyAppointments(
      String patientId, Appointment? lastAppointment) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getPatientsAppointments');
      HttpsCallableResult<dynamic> response = await getDoc(
          {'patientId': patientId, 'lastAppointment': lastAppointment});

      Map<String, dynamic> responseData = response.data;

      print("Appointments Response");
      print(responseData);

      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((e) => Appointment.fromMap(e))
            .toList();
      } else {
        return <Appointment>[];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return <Appointment>[];
    }
  }

  Future<List<Hospital>> getHospitals(Hospital? lastHospital) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getHospitals');
      HttpsCallableResult<dynamic> response =
          await getDoc({'lastHospital': lastHospital});

      Map<String, dynamic> responseData = response.data;

      print("Appointments Response");
      print(responseData);

      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((e) => Hospital.fromMap(e))
            .toList();
      } else {
        return <Hospital>[];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return <Hospital>[];
    }
  }

  Future<List<Doctor>> getAvailableDoctors(
      String speciality, Doctor? lastDoctor) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getAvailableDoctors');
      HttpsCallableResult<dynamic> response =
          await getDoc({'speciality': speciality, 'lastDoctor': lastDoctor});

      Map<String, dynamic> responseData = response.data;

      print("Appointments Response");
      print(responseData);

      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((e) => Doctor.fromMap(e))
            .toList();
      } else {
        return <Doctor>[];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return <Doctor>[];
    }
  }

  Future<List<String>> getAccessRequests(String myId) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getPatientsAccessRequests');
      HttpsCallableResult<dynamic> response = await getDoc({'patientId': myId});

      Map<String, dynamic> responseData = response.data;

      print("Access Requests Response");
      print(responseData);

      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((val) => val.toString())
            .toList();
      } else {
        return <String>[];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return <String>[];
    }
  }

  Future<List<DiagnosticTest>> getCentersTests(
      String centerId, DiagnosticTest? lastTest) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getCentersTests');
      HttpsCallableResult<dynamic> response =
          await getDoc({'centerId': centerId, 'lastTest': lastTest});

      Map<String, dynamic> responseData = response.data;

      print("Appointments Response");
      print(responseData);

      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((e) => DiagnosticTest.fromMap(e))
            .toList();
      } else {
        return <DiagnosticTest>[];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return <DiagnosticTest>[];
    }
  }

  Future<List<Doctor>> getHospitalsDoctors(
      String hospitalId, Doctor? lastDoctor) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getDoctorsForHospital');
      HttpsCallableResult<dynamic> response =
          await getDoc({'hospitalId': hospitalId, 'lastDoctor': lastDoctor});

      Map<String, dynamic> responseData = response.data;

      print("Appointments Response");
      print(responseData);

      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((e) => Doctor.fromMap(e))
            .toList();
      } else {
        return <Doctor>[];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return <Doctor>[];
    }
  }

  Future<List<Doctor>> searchForHospitalDoctors(
      String hospitalId, String queryString) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('searchForHospitalDoctor');
      HttpsCallableResult<dynamic> response =
          await getDoc({'hospitalId': hospitalId, 'queryString': queryString});

      Map<String, dynamic> responseData = response.data;

      print("Appointments Response");
      print(responseData);

      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((e) => Doctor.fromMap(e))
            .toList();
      } else {
        return <Doctor>[];
      }
    } catch (e) {
      print("Error getting search response $e");
      return <Doctor>[];
    }
  }

  Future<List<DiagnosticCenter>> getCentersInArea(
      double lat, double lng) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getCentersInArea');
      HttpsCallableResult<dynamic> response =
          await getDoc({'lat': lat, 'lng': lng});

      Map<String, dynamic> responseData = response.data;

      print("Appointments Response");
      print(responseData);

      if (responseData['status'] == 'success') {
        return (responseData['data'] as List)
            .map((e) => DiagnosticCenter.fromMap(e))
            .toList();
      } else {
        return <DiagnosticCenter>[];
      }
    } catch (e) {
      print("Error getting doctor $e");
      return <DiagnosticCenter>[];
    }
  }

  Future<bool> sendMessage(String chatId, Map chatMessage) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('sendChat');
      HttpsCallableResult<dynamic> response =
          await getDoc({'chatId': chatId, 'message': chatMessage});

      Map<String, dynamic> responseData = response.data;

      print("Data to be rturned");
      print(responseData);
      print(responseData['status']);

      if (responseData['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error sending message $e");
      return false;
    }
  }

  Future<bool> handleAccessRequest(
      String patientId, String doctorId, bool approve) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('handleAccessRequest');
      HttpsCallableResult<dynamic> response = await getDoc(
          {'patientId': patientId, 'doctorId': doctorId, 'approve': approve});

      Map<String, dynamic> responseData = response.data;

      print("Data to be returned");
      print(responseData);
      print(responseData['status']);

      if (responseData['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error sending message $e");
      return false;
    }
  }

  Future<bool> updateProfileInfo(
      BuildContext context, String hospitalId, Map updatedData) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('updateHospitalInfo');
      HttpsCallableResult<dynamic> response =
          await getDoc({'hospitalId': hospitalId, 'updatedData': updatedData});

      Map<String, dynamic> responseData = response.data;

      print("Data to be returned");
      print(responseData);
      print(responseData['status']);

      if (responseData['status'] == 'success') {
        //Reload the patient data
        Hospital? hospital = await getHospitalFromId(hospitalId);

        print("This is the patient gotten");
        print(hospital);
        if (hospital != null) {
          Provider.of<UserStore>(context, listen: false)
              .initializeUser(hospital);
          return true;
        } else {
          return false;
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error sending message $e");
      return false;
    }
  }

  Future<bool> updateDoctorInfo(String doctorId, Map updatedData) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('updateDoctorInfo');
      HttpsCallableResult<dynamic> response =
          await getDoc({'doctorId': doctorId, 'updatedData': updatedData});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == 'success') {
        //Reload the patient data
        Doctor? doctor = await getDoctorFromId(doctorId);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error sending message $e");
      return false;
    }
  }

  Future<bool> updateClerkingReport(String reportId, Map updatedData) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('updateClerkingReport');
      HttpsCallableResult<dynamic> response =
          await getDoc({'reportId': reportId, 'updatedData': updatedData});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error sending message $e");
      return false;
    }
  }

  Future<bool> updateReferralData(String referralId, Map updatedData) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('updateReferralInfo');
      HttpsCallableResult<dynamic> response =
          await getDoc({'referralId': referralId, 'updatedData': updatedData});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error sending message $e");
      return false;
    }
  }

  Future<String> generateAgoraToken(String channelId) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'generateAgoraToken',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 5),
        ),
      );

      var result = await callable
          .call(<String, dynamic>{'uid': 0, 'channelId': channelId});

      return result.data;
    } catch (er) {
      print(er);
      return '';
    }
  }

  Future<int> getUnreadNotifications(String patientId) async {
    try {
      HttpsCallable getDoc = FirebaseFunctions.instance
          .httpsCallable('getNoOfUnreadNotificationsHospital');
      HttpsCallableResult<dynamic> response =
          await getDoc({'hospitalId': patientId});

      Map<String, dynamic> responseData = response.data;

      print("Data to be returned");
      print(responseData);
      print(responseData['status']);

      if (responseData['status'] == 'success') {
        return responseData['data'];
      } else {
        return 0;
      }
    } catch (e) {
      print("Error sending message $e");
      return 0;
    }
  }

  Future<bool> markAllNotificationsAsRead(String patientId) async {
    try {
      HttpsCallable getDoc = FirebaseFunctions.instance
          .httpsCallable('markAllNotificationsAsReadHospital');
      HttpsCallableResult<dynamic> response =
          await getDoc({'hospitalId': patientId});

      Map<String, dynamic> responseData = response.data;

      print("Data to be returned");
      print(responseData);
      print(responseData['status']);

      if (responseData['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error sending message $e");
      return false;
    }
  }

  Stream listenForChatStream(Chat chat) {
    try {
      return _firestoreInstance
          .collection(chatsCollectionName)
          .doc(chat.id)
          .collection(chatsCollectionName)
          .orderBy('timestamp')
          .snapshots()
          .map((event) => event.docs
              .map((e) => ChatMessage.fromFirebaseDocument(e))
              .toList());
    } catch (er) {
      print("Error getting chat stream");
      print(er);
      return Stream.value([]);
    }
  }

  Future<DiagnosticCenter?> getCenterFromId(String userId) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getCenterFromId');
      HttpsCallableResult<dynamic> response =
          await getDoc({'centerId': userId});

      Map<String, dynamic> responseData = response.data;

      // print(responseData, responseData['status'], transactionStatus.success);
      print("This is the center data");
      print(responseData);

      if (responseData['status'] == 'success') {
        var center = DiagnosticCenter.fromMap(responseData['data']);
        print("Center here");
        print(center);
        return center;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting center data $e");
      return null;
    }
  }

  Future<Referral?> getReferralFromId(String referralId) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getReferralFromId');
      HttpsCallableResult<dynamic> response = await getDoc({'id': referralId});

      Map<String, dynamic> responseData = response.data;

      // print(responseData, responseData['status'], transactionStatus.success);
      print("This is the center data");
      print(responseData);

      if (responseData['status'] == 'success') {
        var center = Referral.fromMap(responseData['data']);
        print("Center here");
        print(center);
        return center;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting center data $e");
      return null;
    }
  }

  Future<Appointment?> getAppointmentFromId(String appointmentId) async {
    try {
      print("Doing this $appointmentId");
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getAppointmentFromId');
      HttpsCallableResult<dynamic> response =
          await getDoc({'id': appointmentId});
      print("Here");

      Map<String, dynamic> responseData = response.data;

      // print(responseData, responseData['status'], transactionStatus.success);
      print("This is the center data");
      print(responseData);

      if (responseData['status'] == 'success') {
        var center = Appointment.fromMap(responseData['data']);
        print("Center here");
        print(center);
        return center;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting center data $e");
      return null;
    }
  }

  Future<Object> signUpDoctor(String password, Map patientData) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('signUpDoctor');
      HttpsCallableResult<dynamic> response =
          await getDoc({'password': password, 'doctor': patientData});

      Map<String, dynamic> responseData = response.data;

      // print(responseData, responseData['status'], transactionStatus.success);

      if (responseData['status'] == TransactionStatus.success) {
        //Load the patients data into the store
        return true;
      } else {
        return responseData['data'];
      }
    } catch (e) {
      return "Unexpected Error Occurred";
    }
  }

  Future<bool> createAppointment(appointment) async {
    try {
      print(appointment);
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('createAppointment');
      HttpsCallableResult<dynamic> response = await getDoc(appointment as Map);

      Map<String, dynamic> responseData = response.data;

      // print(responseData, responseData['status'], transactionStatus.success);

      if (responseData['status'] == TransactionStatus.success) {
        return true;
      } else {
        return responseData['data'];
      }
    } catch (e) {
      print('Error creating appointment $e');
      return false;
    }
  }

  Future<Patient?> getPatientFromId(String userId) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getPatientFromUid');
      HttpsCallableResult<dynamic> response = await getDoc({'uid': userId});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == transactionStatusMap['success']) {
        return Patient.fromMap(responseData['data']);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Patient?> getPatientFromPhone(String userId) async {
    try {
      HttpsCallable getDoc =
          FirebaseFunctions.instance.httpsCallable('getPatientFromPhone');
      HttpsCallableResult<dynamic> response =
          await getDoc({'phoneNumber': userId});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == transactionStatusMap['success']) {
        return Patient.fromMap(responseData['data']);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> generateDiagnosisAssist(String data,{
  List<Map<String, dynamic>> selectedFiles = const [],
  File? imageFile,
}) async {
  try {
    final HttpsCallable getPat = FirebaseFunctions.instance.httpsCallable(
      'aiGeneratePossibleDiagnosis',
    );

    Map<String, dynamic> payload = {'data': data};

    if (selectedFiles.isNotEmpty) {
      List<Map<String, String>> base64Files = [];

      for (var fileMap in selectedFiles) {
        File file = fileMap['file'];
        String name = fileMap['name'];

        final bytes = await file.readAsBytes();
        final base64Content = base64Encode(bytes);

        base64Files.add({
          'name': name,
          'base64': base64Content,
        });
      }

      payload['files'] = base64Files;
    }

    final HttpsCallableResult response = await getPat.call(payload);
    final responseData = response.data as Map<String, dynamic>;

    print(responseData);

    if (responseData['status'] == 'success') {
      return responseData['data'] as Map<String, dynamic>; // includes result + imageUrls
    } else {
      return null;
    }
  } catch (error) {
    print("Error calling diagnosis API: $error");
    return null;
  }
}

  Future<dynamic> getClerkingTemplateSettings() async {
    try {
      final HttpsCallable getPat = FirebaseFunctions.instance.httpsCallable(
        'getAdminClerkingSettings',
      );
      final HttpsCallableResult response = await getPat.call({});

      final responseData = response.data as Map<String, dynamic>;

      print("Direct response $responseData");

      if (responseData['status'] == 'success') {
        return responseData['data'];
      } else {
        return null;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> checkIfAccessRequested(String doctorId, String patientId) async {
    try {
      final httpsCallable =
          FirebaseFunctions.instance.httpsCallable('checkIfAccessRequested');
      final response = await httpsCallable.call({
        'doctorId': doctorId,
        'patientId': patientId,
      });

      final responseData = response.data as Map<String, dynamic>;

      print(responseData);
      print(responseData['status']);

      if (responseData['status'] == 'success') {
        return responseData['data'] as bool;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> requestAccessFromPatient(
      String doctorId, String patientId) async {
    try {
      final httpsCallable =
          FirebaseFunctions.instance.httpsCallable('requestAccessFromPatient');
      final response = await httpsCallable.call({
        'doctorId': doctorId,
        'patientId': patientId,
      });

      final responseData = response.data as Map<String, dynamic>;

      print(responseData);
      print(responseData['status']);

      if (responseData['status'] == 'success') {
        return responseData['data'] as bool;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Chat>> getMyChats(String myId, [Chat? lastChat]) async {
    try {
      final HttpsCallable getChats =
          FirebaseFunctions.instance.httpsCallable('getMyChats');

      final response =
          await getChats.call({'userId': myId, 'lastChat': lastChat});

      final responseData = response.data as Map<String, dynamic>;

      // print(responseData, responseData['status'], 'success');

      if (responseData['status'] == 'success') {
        return (responseData['data'] as List<dynamic>)
            .map((chatData) => Chat.fromMap(chatData))
            .toList();
      } else {
        return [];
      }
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<List<String>> uploadFiles(List<File> files) async {
    try {
      List<String> uploadedUrls = [];

      for (File file in files) {
        // Create a unique filename using timestamp
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

        // Create storage reference
        final storageRef =
            FirebaseStorage.instance.ref().child('uploads/$fileName');

        // Upload file
        await storageRef.putFile(file);

        // Get download URL
        String downloadUrl = await storageRef.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }

      return uploadedUrls;
    } catch (e) {
      print('Error uploading files: $e');
      return [];
    }
  }
Future<dynamic> signUpHospital(
  String password,
  Map<String, dynamic> hospitalData,
) async {
    const functionName = 'signUpHospital'; // or 'signUpHospital' based on backend

  try {
    print('[signUpHospital] Initiating signup request...');
        print('[signUpHospital] Preparing to call function: $functionName');

    print('[signUpHospital] Payload:');
    print({'password': '********', 'center': hospitalData}); // Mask password
final accessCode = hospitalData['accessCode'];
    if (accessCode == null || accessCode.isEmpty) {
      print('[signUpHospital] Error: Access code is required.');
      return 'Access code is required.';
    }
    HttpsCallable signUp =
        FirebaseFunctions.instance.httpsCallable(functionName);

    HttpsCallableResult<dynamic> response =
        await signUp.call({'password': password,
         'center': hospitalData,'accessCode':hospitalData['accessCode']});

    print('[signUpHospital] Raw Response: ${response.data}');

    Map<String, dynamic> responseData = response.data;

    if (responseData['status'] == 'success') {
      print('[signUpHospital] Signup successful.');
      return true;
    } else {
      print('[signUpHospital] Signup failed. Message: ${responseData['message']}');
      return responseData['message'] ?? 'An unknown error occurred.';
    }
  } catch (e, stackTrace) {
    print('[signUpHospital] Exception occurred: $e');
    print('[signUpHospital] Stack trace:\n$stackTrace');
    return e.toString();
  }
}


  Future<bool> sendReportToDoctor({
    required String reportId,
    required String doctorId,
  }) async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('sendReportToDoctor');
      final response = await callable.call({
        'reportId': reportId,
        'doctorId': doctorId,
      });

      final responseData = response.data as Map<String, dynamic>;
      return responseData['status'] == 'success';
    } catch (e) {
      print("Error sending report to doctor: $e");
      return false;
    }
  }

  Future<bool> updateHospitalDoctorApproval(
      String hospitalId, String doctorId, bool approved) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('handleDoctorApprovalHospital');
      final response = await callable.call({
        'hospitalId': hospitalId,
        'doctorId': doctorId,
        'approved': approved
      });
      return response.data['status'] == 'success';
    } catch (e) {
      print("Error updating hospital doctor approval: $e");
      return false;
    }
  }

  Future<bool> sendVerificationCode(String phoneNumber) async {
    try {
      HttpsCallable sendCode =
          FirebaseFunctions.instance.httpsCallable('sendVerificationCode');
      final response = await sendCode.call({
        'phoneNumber': phoneNumber,
      });

      final responseData = response.data as Map<String, dynamic>;
      return responseData['status'] == 'success';
    } catch (e) {
      print("Error sending verification code: $e");
      return false;
    }
  }

  Future<bool> verifyCode(String phoneNumber, String code) async {
    try {
      HttpsCallable verifyCode =
          FirebaseFunctions.instance.httpsCallable('verifyCode');
      final response = await verifyCode.call({
        'phoneNumber': phoneNumber,
        'code': code,
      });

      final responseData = response.data as Map<String, dynamic>;
      return responseData['status'] == 'success';
    } catch (e) {
      print("Error verifying code: $e");
      return false;
    }
  }

  Future<List<AppointmentRequest>> getHospitalAppointmentRequests(
      String hospitalId,
      [AppointmentRequest? lastAppointment]) async {
    try {
      HttpsCallable getRequests = FirebaseFunctions.instance
          .httpsCallable('getHospitalAppointmentRequests');

      HttpsCallableResult<dynamic> response = await getRequests(
          {'hospitalId': hospitalId, 'lastAppointment': lastAppointment?.id});

      Map<String, dynamic> responseData = response.data;

      if (responseData['status'] == 'success') {
        List<dynamic> data = responseData['data'] as List<dynamic>;
        return data
            .map((e) => AppointmentRequest.fromMap(e as Map<dynamic, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting hospital appointment requests: $e");
      return [];
    }
  }

  Future<bool> handleHospitalAppointmentRequest(
      String hospitalId, String appointmentId, bool approved) async {
    try {
      HttpsCallable handleRequest = FirebaseFunctions.instance
          .httpsCallable('handleHospitalAppointmentRequest');

      HttpsCallableResult<dynamic> response = await handleRequest({
        'hospitalId': hospitalId,
        'appointmentId': appointmentId,
        'approved': approved
      });

      Map<String, dynamic> responseData = response.data;
      return responseData['status'] == 'success';
    } catch (e) {
      print("Error handling hospital appointment request: $e");
      return false;
    }
  }

  // Future<bool> skipPatientConsent(String hospitalId) async {
  //   try {
  //     HttpsCallable skipConsent =
  //         FirebaseFunctions.instance.httpsCallable('skipPatientConsent');
  //     final response = await skipConsent.call({
  //       'hospitalId': hospitalId,
  //     });

  //     final responseData = response.data as Map<String, dynamic>;
  //     return responseData['status'] == 'success';
  //   } catch (e) {
  //     print("Error skipping patient consent: $e");
  //     return false;
  //   }
  // }

  Stream<List<ChatMessage>> listenForClerkingReportChat(String reportId) {
    return FirebaseFirestore.instance
        .collection('Clerkings')
        .doc(reportId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirebaseDocument(doc))
            .toList());
  }

  Future<void> sendClerkingReportMessage(
    String userId,
    String reportId,
    String message, {
    String? patientPhone,
    String type = 'text',
    String? imageUrl,
  }) async {
    await FirebaseFirestore.instance
        .collection('Clerkings')
        .doc(reportId)
        .collection('messages')
        .add({
      'message': message,
      'sender': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'imageUrl': imageUrl,
    });
  }

  Future<List<String>> uploadFilesToFirebaseStorage(List<File> files) async {
    List<String> downloadURLs = [];

    try {
      for (File file in files) {
        Reference storageRef = _firebaseStorage.ref(file.path);
        await storageRef.putFile(file);

        String downloadURL = await storageRef.getDownloadURL();
        downloadURLs.add(downloadURL);
      }

      return downloadURLs;
    } catch (error) {
      print("Error uploading files: $error");
      rethrow;
    }
  }

  Future<String> uploadFile(String filePath, String destination) async {
    final file = File(filePath);
    final ref = FirebaseStorage.instance.ref().child(destination);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> sendEmailVerification() async {
    final user = firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> isEmailVerified() async {
    await firebaseAuth.currentUser?.reload();
    return firebaseAuth.currentUser?.emailVerified ?? false;
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    await _initializeCloudMessaging();
    await _initializeNotifications();
  }

  Future<void> _initializeCloudMessaging() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  void _handleNotificationTap(NotificationResponse details) {
    print('Notification tapped: ${details.payload}');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notificationData = message.data;
    final notificationType = notificationData['type'];

    await _showLocalNotification(message);

    switch (notificationType) {
      case 'chat':
        break;
      case 'appointment':
        break;
      case 'referral':
        break;
      default:
        break;
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            channelDescription: 'Default notification channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> subscribeToUserTopics(String userId) async {
    try {
      await _messaging.subscribeToTopic(userId);
      debugPrint('Subscribed to $userId');
    } catch (e) {
      debugPrint('Error subscribing to user topics: $e');
    }
  }

  Future<void> unsubscribeFromUserTopics(String userId) async {
    try {
      await _messaging.unsubscribeFromTopic(userId);
      debugPrint('Unsubscribed from $userId');
    } catch (e) {
      debugPrint('Error unsubscribing from user topics: $e');
    }
  }

  Future<bool> deleteClerkingReport(String reportId) async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('deleteClerkingReport');
      final response = await callable.call({
        'reportId': reportId,
      });

      final responseData = response.data as Map<String, dynamic>;
      return responseData['status'] == 'success';
    } catch (e) {
      print("Error deleting report: $e");
      return false;
    }
  }

  /// Submits the image (optional) and clerking details to the backend for AI analysis.
  Future<String?> analyzeImageWithAI(File? image, String clerkingDetails) async {
    try {
      String? base64Image;
      if (image != null) {
        // Read image bytes
        final bytes = await image.readAsBytes();
        base64Image = base64Encode(bytes);
      }
      // Call the backend (Firebase Function) for AI analysis
      final HttpsCallable analyzeImageFn =
          FirebaseFunctions.instance.httpsCallable('analyzeImageWithAIBackend');
      final response = await analyzeImageFn.call({
        if (base64Image != null) 'imageBase64': base64Image,
        'clerkingDetails': clerkingDetails,
      });

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['status'] == 'success') {
        return responseData['result'] as String;
      } else {
        print('Backend AI analysis error: \\${responseData['message']}');
        return null;
      }
    } catch (e) {
      print('Error submitting image for AI analysis: $e');
      return null;
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}
