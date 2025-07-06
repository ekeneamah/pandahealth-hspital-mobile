import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';

class CustomIconButton extends StatelessWidget {
  final String? image;
  final IconData? icon;
  final VoidCallback? onPressed;
  const CustomIconButton({super.key, this.image, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
          padding: const EdgeInsets.all(0),
          onPressed: onPressed,
          icon: Material(
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: const BorderSide(color: darkGreen, width: 2)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: icon != null
                  ? Icon(
                      icon,
                      color: darkGreen,
                      size: 22,
                    )
                  : Image.asset(image!, height: 18),
            ),
          )),
    );
  }
}
