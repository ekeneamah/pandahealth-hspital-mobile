import 'package:flutter/material.dart';

class NoReferralsWidget extends StatelessWidget {
  final String text;
  const NoReferralsWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 180,
        width: double.infinity,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('images/empty.png', height: 110),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          )
        ]));
  }
}
