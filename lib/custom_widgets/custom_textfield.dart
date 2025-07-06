import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String? hintText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Color? fillColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final int maxLines;
  final TextAlign? textAlign;
  final bool? autoFocus;
  final int? maxLength;
  final bool? filled;
  final Widget? suffixIcon;
  final bool? hasBorderside;
  final Iterable<String>? autofillHints;
  final bool? readOnly;
  final String? initialValue;

  const CustomTextfield({
    super.key,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.controller,
    this.textInputAction,
    this.onEditingComplete,
    this.focusNode,
    this.autoFocus = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.words,
    this.onChanged,
    this.maxLines = 1,
    this.filled = true,
    this.hasBorderside = true,
    this.fillColor = Colors.white,
    this.maxLength,
    this.textStyle,
    this.textAlign,
    this.suffixIcon,
    this.autofillHints,
    this.readOnly = false,
    this.initialValue,
    this.onTap,
    this.prefixIcon,
    this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: TextFormField(
        onTap: onTap,
        initialValue: initialValue,
        textAlign: textAlign ?? TextAlign.start,
        onChanged: onChanged,
        autofocus: autoFocus!,
        cursorColor: Colors.black,
        keyboardType: keyboardType,
        focusNode: focusNode,
        onEditingComplete: onEditingComplete,
        textInputAction: textInputAction,
        readOnly: readOnly!,
        controller: controller,
        cursorWidth: 1.0,
        maxLines: maxLines,
        obscureText: obscureText,
        maxLength: maxLength,
        validator: validator,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintStyle:
              hintStyle ?? const TextStyle(fontSize: 16, color: Colors.grey),
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
          fillColor: fillColor,
          filled: filled,
          hintText: hintText,
        ),
        style: textStyle ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
