import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/constants/data.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class InLineText extends StatelessWidget {
  const InLineText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: const TextStyle(color: darkBlue),
            text:
                'By clicking Join Now or Sign Up with Google, or Facebook you Agree to Panda Health ',
            children: [
          TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Handle tap here
                  print('TextSpan tapped!');
                  openLink(tocWebsite);
                },
              style: const TextStyle(color: Color(0xfffece5b)),
              text: 'Terms of Use '),
          const TextSpan(text: 'and '),
          TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Handle tap here
                  print('TextSpan tapped!');
                  openLink(tocWebsite);
                },
              style: const TextStyle(color: Color(0xfffece5b)),
              text: 'Privacy Policy '),
          const TextSpan(text: 'and '),
          const TextSpan(style: TextStyle(color: Color(0xfffece5b)), text: 'HIPAA '),
          const TextSpan(text: 'Authorization Statement.'),
        ]));
  }
}
