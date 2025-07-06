import 'package:flutter/material.dart';

import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/button_loader.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/screens/auth/set_passcode/set_passcode_view.dart';
import 'package:pandahealthhospital/screens/tabs_screen.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/utils/app_functions.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPScreen extends StatefulWidget {
  final String verificationCode;
  const OTPScreen(this.verificationCode, {super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool isLoading = false;

  final FirebaseServices _firebaseServices = FirebaseServices();

  TextEditingController otpController = TextEditingController();

  verifyCode() async {
    bool res = await _firebaseServices.verifyPhoneAuthCode(
        context, widget.verificationCode, otpController.text);
    if (res) {
      push(const BottomNavigationScreen());
    } else {
      showCustomErrorToast("Couldn't verify otp");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          // key: n.formkey,
          child: Column(
            children: [
              const SizedBox(height: 35),
              const CustomTitleBar(image: 'images/app-icon.png'),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    'Verify your number with\ncode sent to your phone number.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: darkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 20),
              Image.asset('images/otp.png', height: 200),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: PinCodeTextField(
                  appContext: context,
                  // controller: n.otpCtrl,
                  controller: otpController,
                  cursorColor: Colors.black,
                  length: 6,
                  validator: (value) => value!.isEmpty
                      ? 'Please enter the OTP sent to your email.'
                      : null,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('I didn\'t receive the code,',
                      style: TextStyle(color: lightGreen)),
                  const SizedBox(width: 4),
                  isLoading
                      ? const Center(
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)),
                        )
                      : GestureDetector(
                          // onTap: () => n.verifyUserEmail(),
                          child: const Text('Resend',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: darkBlue)),
                        )
                ],
              ),
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                    radius: 22,
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      //ToDo: Replace with actual login flow
                      verifyCode();
                    },
                    gradient: const [lightGreen, darkGreen],
                    child:
                        ButtonLoader(isLoading: isLoading, text: 'CONTINUE')),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
