import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/button_loader.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/screens/auth/signin/signin_view.dart';
import 'package:pandahealthhospital/utils/app_functions.dart';
import 'package:pandahealthhospital/utils/utils.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

class SignInWithPasscode extends StatefulWidget {
  const SignInWithPasscode({super.key});

  @override
  State<SignInWithPasscode> createState() => _SignInWithPasscodeState();
}

class _SignInWithPasscodeState extends State<SignInWithPasscode> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final otpCtrl = TextEditingController();
    final formkey = GlobalKey<FormState>();
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('images/app-icon.png', height: 50),
                const SizedBox(height: 20),
                const Text('Please login with your passcode',
                    style: TextStyle(
                        color: darkBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 80),
                Image.asset('images/lock.png', height: 100),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PinCodeTextField(
                    appContext: context,
                    controller: otpCtrl,
                    autoFocus: true,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.black,
                    length: 4,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your passcode.' : null,
                    // onCompleted: (value) => notifier.loginWithPasscode(
                    //     otpCtrl.text.trim(), formkey),
                    onChanged: (val) {},
                    pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(15),
                        fieldHeight: 50,
                        inactiveColor: Colors.green.shade200,
                        fieldWidth: 50,
                        activeFillColor: lightGreen),
                  ),
                ),
                const SizedBox(height: 50),
                CustomButton(
                  isLoading: isLoading,
                  radius: 22,
                  // onPressed: () => notifier.loginWithPasscode(
                  //     otpCtrl.text.trim(), formkey),
                  gradient: showGradient(isLoading),
                  child: ButtonLoader(isLoading: isLoading, text: 'NEXT'),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: CustomButton(
                    height: 40,
                    onPressed: () => navigateToScreen(context, const SignInView()),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Forgot Passcode?',
                            style: TextStyle(color: lightGreen)),
                        SizedBox(width: 4),
                        Text('Sign in with Email',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, color: darkBlue))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
