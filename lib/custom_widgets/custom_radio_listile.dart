import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';

class LabeledRadio extends StatelessWidget {
  LabeledRadio({
    super.key,
    required this.label,
    required this.padding,
    this.subWidget,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  Widget? subWidget;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(color: darkBlue),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                subWidget ?? Container(),
                const SizedBox(width: 5),
                CustomCheckbox(
                  isChecked: value,
                  onChange: onChanged,
                  size: 25,
                  selectedColor: primaryColor,
                )
                // Checkbox(
                //     value: value,
                //     onChanged: (val) {
                //       print("new value $val");
                //       onChanged(!val!);
                //     }),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomCheckbox extends StatelessWidget {
  final Function onChange;
  final bool isChecked;
  double? size;
  double? iconSize;
  Color? selectedColor;
  Color? selectedIconColor;
  Color? borderColor;
  Icon? checkIcon;

  CustomCheckbox(
      {super.key, required this.isChecked,
      required this.onChange,
      this.size,
      this.iconSize,
      this.selectedColor,
      this.selectedIconColor,
      this.borderColor,
      this.checkIcon});

  @override
  Widget build(BuildContext context) {
    print("Building with $isChecked");

    return AnimatedContainer(
      margin: const EdgeInsets.all(4),
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastLinearToSlowEaseIn,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isChecked ? selectedColor ?? Colors.blue : Colors.transparent,
        // borderRadius: BorderRadius.circular(3.0),
        //
        // border: Border.all(
        //   color: borderColor ?? Colors.black,
        //   width: 1.5,
        // )
      ),
      width: size ?? 18,
      height: size ?? 18,
      child: isChecked
          ? Icon(
              Icons.check,
              color: selectedIconColor ?? Colors.white,
              size: iconSize ?? 14,
            )
          : null,
    );
  }
}
