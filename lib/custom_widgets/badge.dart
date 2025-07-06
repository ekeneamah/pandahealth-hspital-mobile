import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/models/hospital.dart';
import 'package:pandahealthhospital/screens/notifications/notifications_view.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:provider/provider.dart';

class PandaBadge extends StatefulWidget {
  const PandaBadge({super.key});

  @override
  State<PandaBadge> createState() => _PandaBadgeState();
}

class _PandaBadgeState extends State<PandaBadge> {
  final FirebaseServices _firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    Hospital hospital =
        Provider.of<UserStore>(context, listen: false).hospital!;

    return Stack(
      children: [
        IconButton(
          onPressed: () async {
            MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => const NotificationView());
            await Navigator.push(context, route);

            // Mark all notifications as read when returning from NotificationView
            await _firebaseServices.markAllNotificationsAsRead(hospital.id);

            // Force refresh the badge count
            setState(() {});
          },
          icon: const Icon(
            Icons.notifications_outlined,
            color: lightGreen,
            size: 32,
          ),
        ),
        FutureBuilder(
          future: _firebaseServices.getUnreadNotifications(hospital.id),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data! > 0) {
              return Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor: lightGreen,
                  child: Text(
                    "${snapshot.data}",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
