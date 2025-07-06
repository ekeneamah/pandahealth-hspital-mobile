import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';

class AppOutlinedButton extends StatelessWidget {
  final onPressed;

  final Widget child;

  double? width;

  final bool withBorderRadius;

  AppOutlinedButton(
      {required this.onPressed,
      this.withBorderRadius = false,
      required this.child,
      this.width,
      super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: withBorderRadius
                ? BorderRadius.circular(defaultCardBorderRadius)
                : BorderRadius.zero),
        side: const BorderSide(width: 1.0, color: primaryColor),
      ),
      onPressed: onPressed,
      child: Container(
          width: width,
          alignment: Alignment.center,
          height: defaultButtonHeight,
          child: child),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  final onPressed;

  Color? customColor;

  double? width;

  final Widget child;

  final bool withBorderRadius;

  AppPrimaryButton(
      {required this.onPressed,
      this.width,
      this.customColor,
      this.withBorderRadius = false,
      required this.child,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: customColor,
        shape: RoundedRectangleBorder(
            borderRadius: withBorderRadius
                ? BorderRadius.circular(defaultCardBorderRadius)
                : BorderRadius.zero),
      ),
      onPressed: onPressed,
      child: Container(
          width: width,
          alignment: Alignment.center,
          height: defaultButtonHeight,
          child: child),
    );
  }
}
