import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/buttons.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/screens/tabs_screen.dart';
import 'package:pandahealthhospital/utils/app_functions.dart';

class FingerprintAuthView extends StatelessWidget {
  const FingerprintAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Login Faster, set up\nTouch ID',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, color: lightGreen, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 80),
          Image.asset('images/security.png'),
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: CustomButton(
              text: 'Enable',
              onPressed: () async {
                //ToDo: Implement local auth with password
                // LocalAuthentication auth = LocalAuthentication();
                // print(await auth.canCheckBiometrics);
              },
              radius: 22,
              gradient: const [lightGreen, darkGreen],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: CustomButton(
                text: 'skip'.toUpperCase(),
                onPressed: () {
                  navigateToScreen(context, const BottomNavigationScreen());
                },
                textColor: lightGreen,
                radius: 22,
                borderSide: const BorderSide(color: lightGreen)),
          )
        ],
      ),
    );
  }
}
