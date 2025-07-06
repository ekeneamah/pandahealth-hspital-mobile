import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'custom_button.dart';

class PandaErrorWidget extends StatelessWidget {
  final VoidCallback onTap;
  final double? fontSize;
  const PandaErrorWidget(this.onTap, {super.key, this.fontSize});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 180,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'We are unable to load this page\nkindly check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fontSize ?? 17,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              CustomButton(
                text: 'Retry',
                radius: 80,
                height: 40,
                width: 150,
                textColor: lightGreen,
                onPressed: onTap,
                borderSide: const BorderSide(color: lightGreen),
              )
            ],
          ),
        ),
      );
}
