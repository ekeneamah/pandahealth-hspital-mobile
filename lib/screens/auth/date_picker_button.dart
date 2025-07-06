import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/buttons.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';

class DatePickerButton extends StatelessWidget {
  final String img, text, date;
  final VoidCallback onTap;
  final Color borderColor;
  const DatePickerButton({
    super.key,
    required this.img,
    required this.date,
    this.borderColor = lightGreen,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      radius: 15,
      borderSide: BorderSide(color: borderColor),
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                  color: lightGreen, fontWeight: FontWeight.w700),
            ),
            Text(
              date,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: darkBlue),
            ),
            Image.asset(img, height: 25, color: darkGreen)
          ],
        ),
      ),
    );
  }
}
