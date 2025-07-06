import 'package:flutter/material.dart';

class MediumSpace extends StatelessWidget {
  const MediumSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 30);
  }
}

class SmallSpace extends StatelessWidget {
  const SmallSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 15);
  }
}

class LargeSpace extends StatelessWidget {
  const LargeSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 50);
  }
}
