import 'package:flutter/material.dart';

import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/button_loader.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/custom_widgets/login_textfield.dart';
import 'package:pandahealthhospital/screens/auth/form_validation.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
// import 'package:healthpanda_patient/widgets/custom_textfield.dart';

class ForgotPasswordEmail extends StatefulWidget {
  const ForgotPasswordEmail({super.key});

  @override
  State<ForgotPasswordEmail> createState() => _ForgotPasswordEmailState();
}

class _ForgotPasswordEmailState extends State<ForgotPasswordEmail> {
  final formkey = GlobalKey<FormState>();
  final userCtrl = TextEditingController();

  bool isLoading = false;

  void _handleResetPassword() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final success =
          await FirebaseServices().resetPassword(userCtrl.text.trim());

      setState(() {
        isLoading = false;
      });

      if (success) {
        showCustomToast("Password reset email sent. Please check your inbox.");
        Navigator.pop(context);
      } else {
        showCustomErrorToast("Failed to send reset email. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SafeArea(
              minimum: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Form(
                  key: formkey,
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      const CustomTitleBar(image: 'images/app-icon.png'),
                      const SizedBox(height: 35),
                      const Text(
                        'Forgot Your Password?',
                        style: TextStyle(
                            color: darkBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 30),
                      Image.asset('images/email_locked.png', height: 185),
                      const SizedBox(height: 30),
                      const Text(
                        'Enter your registered email address',
                        style: TextStyle(
                            color: darkBlue, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We will send a password reset link to your email',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),
                      LoginTextField(
                          controller: userCtrl,
                          hint: 'Email',
                          checkboxCtrl: userCtrl,
                          textCapitalization: TextCapitalization.none,
                          isValidated: emailRegExp.hasMatch(userCtrl.text),
                          validator: (val) => validateEmail(val!),
                          onChanged: (val) => setState(() {})),
                      const SizedBox(height: 50),
                      CustomButton(
                        isLoading: isLoading,
                        onPressed: _handleResetPassword,
                        radius: 20,
                        gradient: showGradient(isLoading),
                        child:
                            ButtonLoader(isLoading: isLoading, text: 'VERIFY'),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              )),
        ));
  }
}
