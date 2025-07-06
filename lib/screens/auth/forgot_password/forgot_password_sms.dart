import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/button_loader.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/utils/utils.dart';

// import 'package:phone_form_field/phone_form_field.dart';

class ForgotPasswordSMS extends StatefulWidget {
  const ForgotPasswordSMS({super.key});

  @override
  State<ForgotPasswordSMS> createState() => _ForgotPasswordSMSState();
}

class _ForgotPasswordSMSState extends State<ForgotPasswordSMS> {
  static String nsn = '';
  // static PhoneNumber number = PhoneNumber(isoCode: IsoCode.NG, nsn: nsn);
  // PhoneController phoneController = PhoneController(initialValue: number);

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SafeArea(
              minimum: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const CustomTitleBar(image: 'images/app-icon.png'),
                    const SizedBox(height: 35),
                    const Text(
                      'Forgot Your Password?',
                      style: TextStyle(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),
                    Image.asset('images/phone-lock.png', height: 180),
                    const SizedBox(height: 25),
                    const Text(
                      'Enter your registered Phone',
                      style: TextStyle(
                          color: darkBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'We will send a code to your number',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    // DecoratedBox(
                    //   decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(20),
                    //       border: Border.all(color: lightGreen)),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(
                    //         left: 20, right: 20, top: 8, bottom: 8),
                    //     child: PhoneFormField(
                    //         controller: phoneController,
                    //         defaultCountry: IsoCode.NG,
                    //         onChanged: (value) =>
                    //             setState(() => nsn = value!.nsn),
                    //         cursorColor: Colors.black,
                    //         cursorWidth: 1,
                    //         style: const TextStyle(
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.w700,
                    //             color: darkBlue),
                    //         decoration: const InputDecoration(
                    //             hintText: 'Phone number',
                    //             hintStyle:
                    //                 TextStyle(fontSize: 16, color: Colors.grey),
                    //             focusedErrorBorder: InputBorder.none,
                    //             focusedBorder: InputBorder.none,
                    //             enabledBorder: InputBorder.none)),
                    //   ),
                    // ),
                    const SizedBox(height: 50),
                    CustomButton(
                      isLoading: isLoading,
                      // onPressed: () => ref
                      //     .read(forgotPasswordViewNotifier.notifier)
                      //     .getResetPasswordLink(
                      //     phoneController.value!.international),
                      radius: 20,
                      gradient: showGradient(isLoading),
                      child: ButtonLoader(isLoading: isLoading, text: 'VERIFY'),
                    )
                  ],
                ),
              )),
        ));
  }
}
