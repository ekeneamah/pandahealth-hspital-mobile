import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';

import 'custom_textfield.dart';

class LoginTextField extends StatelessWidget {
  final String? hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool isValidated;
  final TextEditingController? checkboxCtrl;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  const LoginTextField({
    super.key,
    this.hint,
    this.checkboxCtrl,
    this.validator,
    this.onChanged,
    this.controller,
    this.isValidated = false,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.words,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(25),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 5),
          child: Row(
            children: [
              Expanded(
                  child: CustomTextfield(
                      controller: controller,
                      prefixIcon: prefixIcon,
                      obscureText: obscureText,
                      suffixIcon: suffixIcon,
                      autofillHints: autofillHints,
                      textCapitalization: textCapitalization,
                      keyboardType: TextInputType.emailAddress,
                      textStyle: const TextStyle(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                      hintText: hint,
                      validator: validator,
                      onChanged: onChanged)),
              if (checkboxCtrl != null && checkboxCtrl!.text.isNotEmpty)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isValidated ? lightGreen : Colors.red,
                  child: Icon(isValidated ? Icons.done : Icons.clear,
                      size: 15, color: Colors.white),
                )
            ],
          ),
        ),
      ),
    );
  }
}
