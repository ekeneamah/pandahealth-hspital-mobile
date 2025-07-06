import 'package:flutter/material.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class BodyWrapper extends StatelessWidget {
  final Widget child;

  const BodyWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = getWidth(context);
    return SizedBox(
        width: width,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
                color: Colors.white,
                elevation: 3,
                borderRadius: BorderRadius.circular(25),
                child: Padding(
                    padding: const EdgeInsets.all(16.0), child: child))));
  }
}
