import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class PatientProfileView extends StatelessWidget {
  const PatientProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: backgroundDecoration(false),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 25),
                const Align(alignment: Alignment.topLeft, child: BackButton()),
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(radius: 40),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Dr. James John',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: darkBlue),
                ),
                const Text('02/01/1999'),
                const Text('Male'),
                TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit')),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          buildHeaderItem('Contact'),
                          buildProfileItems('Phone No.', '23470300258956'),
                          buildProfileItems('Email', 'arinze@panda.com'),
                          buildProfileItems(
                              'Address', 'lekki Phase 1, Nigeria'),
                          const SizedBox(height: 20),
                          buildHeaderItem('Security'),
                          buildProfileItems('Change Password', ''),
                          buildProfileItems('Change Passcode', ''),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileItems(String title, String text) => CustomButton(
        radius: 8,
        child: Row(
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, color: darkBlue),
            ),
            const Spacer(),
            Text(text),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      );
  Widget buildHeaderItem(String text) => Container(
      alignment: Alignment.centerLeft,
      height: 45,
      width: double.infinity,
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w800, color: darkGreen),
        ),
      ));
}
