import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/screens/auth/signin/signin_view.dart';
import 'package:pandahealthhospital/screens/auth/signup/signup_view.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text('Referrals Made Easy',
                  style: TextStyle(color: lightGreen, fontSize: 15)),
              const SizedBox(height: 35),
              Image.asset('images/splash.png', height: 250),
              const Text('We make referrals fast and easy',
                  style: TextStyle(color: lightGreen)),
              const SizedBox(height: 50),
              const CircleAvatar(radius: 8, backgroundColor: lightGreen),
              const SizedBox(height: 20),
              CustomButton(
                  radius: 22,
                  onPressed: () => push(const SignInView()),
                  gradient: const [lightGreen, darkGreen],
                  text: 'SIGN IN'),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: CustomButton(
                  height: 40,
                  onPressed: () => push(const SignUpView()),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: TextStyle(color: lightGreen)),
                      SizedBox(width: 4),
                      Text('Sign Up',
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
