import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/buttons.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/screens/auth/signin/signin_view.dart';

import 'package:pandahealthhospital/utils/app_functions.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final width = getWidth(context);
    final height = getHeight(context);

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('images/app-icon.png', height: 50),
              const SizedBox(height: 20),
              const Text('This is Panda Health,\nWelcome!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: darkBlue,
                      fontSize: 25,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              const Text('Your best friend for all your medical needs',
                  style: TextStyle(color: lightGreen, fontSize: 15)),
              const SizedBox(height: 35),
              Image.asset('images/splash.png', height: 250),
              const Text('Schedule Doctor appointments with ease.',
                  style: TextStyle(color: lightGreen)),
              const SizedBox(height: 50),
              const CircleAvatar(radius: 8, backgroundColor: lightGreen),
              const SizedBox(height: 20),
              CustomButton(
                  radius: 22,
                  onPressed: () => navigateToScreen(context, Container()),
                  gradient: const [lightGreen, darkGreen],
                  text: 'GET STARTED'),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: CustomButton(
                  height: 40,
                  onPressed: () => navigateToScreen(context, const SignInView()),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?',
                          style: TextStyle(color: lightGreen)),
                      SizedBox(width: 4),
                      Text('Sign In',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: darkBlue))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
