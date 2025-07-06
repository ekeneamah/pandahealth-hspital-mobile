import 'package:flutter/material.dart';

class ButtonLoader extends StatelessWidget {
  final bool isLoading;
  final String? text;
  final Color? color;
  final TextStyle? style;
  final Color? spinnerColor;
  const ButtonLoader(
      {super.key,
      required this.isLoading,
      required this.text,
      this.color = Colors.white,
      this.spinnerColor,
      this.style});

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Text(
            text!,
            style: style ?? TextStyle(color: color, fontSize: 18),
          )
        : Center(
            child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: spinnerColor ?? Colors.white, strokeWidth: 2)),
          );
  }
}
