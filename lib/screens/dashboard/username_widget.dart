import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:provider/provider.dart';

class UsernameWidget extends StatefulWidget {
  const UsernameWidget({super.key});

  @override
  State<UsernameWidget> createState() => _UsernameWidgetState();
}

class _UsernameWidgetState extends State<UsernameWidget> {
  String username = '';

  late UserStore store;

  @override
  void initState() {
    super.initState();
    store = Provider.of<UserStore>(context, listen: false);
    username = store.hospital!.name;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Good ${greetings()} $username,",
          style: const TextStyle(
              color: darkBlue, fontWeight: FontWeight.w700, fontSize: 22),
        ),
        const SmallSpace(),
        // Text(
        //   getRandomHealthPositiveMessage(),
        //   style: const TextStyle(color: Colors.black, fontSize: 15),
        // ),
      ],
    );
  }

  String greetings() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }
}
