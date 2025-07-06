import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/screens/auth/forgot_password/forgot_password_email.dart';
import 'package:pandahealthhospital/utils/app_functions.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CustomTitleBar(image: 'images/app-icon.png'),
            const SizedBox(height: 20),
            const Text('Forgot your password?',
                style: TextStyle(
                    color: darkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Image.asset('images/forgot_password.png', height: 200),
            const SizedBox(height: 20),
            const Text('Reset your password via email',
                style: TextStyle(
                    color: darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 50),
            buildButton(() => navigateToScreen(context, const ForgotPasswordEmail()),
                'Reset Password', Icons.email_outlined),
          ],
        ),
      ),
    );
  }

  Widget buildButton(VoidCallback onTap, String text, IconData icon) =>
      CustomButton(
        width: 300,
        color: lightGreen.withOpacity(0.3),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32),
            const Spacer(),
            Text(
              text,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54),
            ),
            const Spacer()
          ],
        ),
      );
}
