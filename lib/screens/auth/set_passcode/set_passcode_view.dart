import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/button_loader.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/screens/auth/fingerprint_auth/fingerprint_auth_view.dart';
import 'package:pandahealthhospital/utils/app_functions.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SetPasscodeView extends StatelessWidget {
  SetPasscodeView({super.key});

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final otpCtrl = TextEditingController();
    final formkey = GlobalKey<FormState>();
    return WillPopScope(
      onWillPop: () async => Future.value(false),
      child: Scaffold(
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
                  const Text('Please create a 4-Digit Pin',
                      style: TextStyle(
                          color: darkBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 80),
                  Image.asset('images/create_pin.png',
                      width: MediaQuery.of(context).size.width * .5),
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
                      validator: (value) => value!.isEmpty
                          ? 'Please enter the OTP sent to your email.'
                          : null,
                      onCompleted: (value) {
                        //ToDo: Implement normal flow
                        // notifier.navigateToConfirmPasscodeViewWithDelay(
                        //     value, formkey);
                      },
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
                    onPressed: () {
                      navigateToScreen(context, const FingerprintAuthView());
                      // notifier.navigateToConfirmPasscodeViewWithDelay(
                      //     otpCtrl.text, formkey),
                    },
                    gradient: showGradient(isLoading),
                    child: ButtonLoader(isLoading: isLoading, text: 'NEXT'),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
