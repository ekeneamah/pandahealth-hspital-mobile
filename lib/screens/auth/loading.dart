import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/screens/auth/onboarding.dart';
import 'package:pandahealthhospital/screens/tabs_screen.dart';
import 'package:pandahealthhospital/screens/welcome_screen/welcome_screen.dart';
import 'package:pandahealthhospital/screens/auth/email_validation/awaiting_email_validation.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices();

  @override
  void initState() {
    super.initState();
    checkAuthState();
  }

  Future<void> checkAuthState() async {
    try {
      final user =
          await _firebaseServices.firebaseAuth.authStateChanges().first;

      // showCustomToast("User: ${user?.uid}");

      if (user == null) {
        showCustomToast("No user logged in");
        // No user logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
        return;
      }

      // Check if user is a healthcare centre
      final isSignedIn =
          await _firebaseServices.checkIfHospitalSignedIn(context);

      // Check if email is verified
      if (!kDebugMode) {
        if (!user.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AwaitingEmailValidationScreen(),
            ),
          );
          return;
        }
      }

      // showCustomToast("User is signed in ${isSignedIn}");

      await Future.delayed(const Duration(seconds: 5));

      if (isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const BottomNavigationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = getWidth(context);
    final height = getHeight(context);

    return Scaffold(
        backgroundColor: cardBackgroundColor,
        body: SizedBox(
            width: width,
            height: height,
            child: const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(appPrimaryColor),
            ))));
  }
}
