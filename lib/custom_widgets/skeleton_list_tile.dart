import 'package:flutter/material.dart';

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(backgroundColor: Colors.grey),
      title: Container(
        width: double.infinity,
        height: 16.0,
        color: Colors.grey,
      ),
      subtitle: Container(
        width: double.infinity,
        height: 12.0,
        color: Colors.grey,
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
