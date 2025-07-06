import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/button_loader.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ConfirmPasscodeView extends StatefulWidget {
  final String value;
  const ConfirmPasscodeView({super.key, required this.value});

  @override
  State<ConfirmPasscodeView> createState() => _ConfirmPasscodeViewState();
}

class _ConfirmPasscodeViewState extends State<ConfirmPasscodeView> {
  String value = "";

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    value = widget.value;
  }

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
                const CustomTitleBar(image: 'images/app-icon.png'),
                const SizedBox(height: 20),
                const Text('Retype Your Pin',
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
                    keyboardType: TextInputType.number,
                    autoFocus: true,
                    cursorColor: Colors.black,
                    length: 4,
                    onCompleted: (val) {
                      //ToDo: Implement normal flow
                      // notifier.confirmUserPasscodeAndNavigateToHomeView(
                      //     val, formkey),
                    },
                    validator: (val) => !val!.contains(value)
                        ? 'Pin unmatch, Please confirm your pin.'
                        : null,
                    onChanged: (val) async {},
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
                  // onPressed: () =>
                  //     notifier.confirmUserPasscodeAndNavigateToHomeView(
                  //         otpCtrl.text, formkey),
                  gradient: showGradient(isLoading),
                  child: ButtonLoader(isLoading: isLoading, text: 'CONTINUE'),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
