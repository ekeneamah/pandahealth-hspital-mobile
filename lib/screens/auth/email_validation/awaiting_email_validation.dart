import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/screens/auth/loading.dart';
import 'package:pandahealthhospital/screens/tabs_screen.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class AwaitingEmailValidationScreen extends StatefulWidget {
  const AwaitingEmailValidationScreen({super.key});

  @override
  State<AwaitingEmailValidationScreen> createState() =>
      _AwaitingEmailValidationScreenState();
}

class _AwaitingEmailValidationScreenState
    extends State<AwaitingEmailValidationScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  Timer? _timer;
  bool isResending = false;
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkHospitalAccount();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkHospitalAccount() {
    final email = _firebaseServices.firebaseAuth.currentUser?.email;
    if (email == 'hospital@yalzapp.com') {
      // Proceed immediately for hospital account
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const BottomNavigationScreen()),
        (route) => false,
      );
    }
  }

  void _startEmailVerificationCheck() {
    final email = _firebaseServices.firebaseAuth.currentUser?.email;
    // Only start verification check for non-hospital accounts
    if (email != 'hospital@yalzapp.com') {
      // Check every 3 seconds
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        final isVerified = await _firebaseServices.isEmailVerified();
        if (isVerified) {
          _timer?.cancel();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const BottomNavigationScreen()),
              (route) => false,
            );
          }
        }
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => isResending = true);
    try {
      await _firebaseServices.sendEmailVerification();
      showCustomToast('Verification email sent successfully');
    } catch (e) {
      showCustomErrorToast('Failed to send verification email');
    }
    setState(() => isResending = false);
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => isChecking = true);
    try {
      final isVerified = await _firebaseServices.isEmailVerified();
      if (isVerified) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const BottomNavigationScreen()),
          (route) => false,
        );
      } else {
        showCustomToast('Email not verified yet. Please check your inbox.');
      }
    } catch (e) {
      showCustomErrorToast('Failed to check verification status');
    }
    setState(() => isChecking = false);
  }

  Future<void> _signOut() async {
    try {
      await _firebaseServices.firebaseAuth.signOut();
      if (mounted) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoadingScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      showCustomErrorToast('Failed to sign out');
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _firebaseServices.firebaseAuth.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: darkBlue),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/confirmation.png', height: 200),
              const SizedBox(height: 32),
              const Text(
                'Verify your email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification link to $email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                isLoading: isChecking,
                onPressed: _checkVerificationStatus,
                gradient: showGradient(isChecking),
                child: const Text('I\'ve verified my email'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: isResending ? null : _resendVerificationEmail,
                child: isResending
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Resend verification link',
                        style: TextStyle(color: lightGreen),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _signOut,
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
