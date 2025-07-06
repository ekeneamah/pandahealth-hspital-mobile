import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:app_badge_plus/app_badge_plus.dart';

import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_loading_widget.dart';
import 'package:pandahealthhospital/models/app_notification.dart';
import 'package:pandahealthhospital/models/appointment.dart';
import 'package:pandahealthhospital/models/chat.dart';
import 'package:pandahealthhospital/models/clerking_report.dart';
import 'package:pandahealthhospital/models/diagnostic_center.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/hospital.dart';
import 'package:pandahealthhospital/models/patient.dart';

import 'package:pandahealthhospital/screens/connect/chat.dart';
import 'package:pandahealthhospital/screens/hospital/hospital_appointments.dart';
import 'package:pandahealthhospital/screens/hospital/hospital_referrals.dart';
import 'package:pandahealthhospital/screens/hospital/view_clerking_report.dart';
import 'package:pandahealthhospital/screens/hospital/view_clerking_reports.dart';

import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/app_functions.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:provider/provider.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  late Hospital hospital;

  @override
  void initState() {
    super.initState();
    hospital = Provider.of<UserStore>(context, listen: false).hospital!;
    _firebaseServices.markAllNotificationsAsRead(hospital.id);
    // Clear the app badge when notifications screen is opened
    AppBadgePlus.updateBadge(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomTitleBar(
        title: 'Notifications',
        showBackButton: true,
      ),
      body: Container(
        decoration: backgroundDecoration(false),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "images/notification_design.png",
                    height: 100,
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: Material(
                        elevation: 3,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: FutureBuilder(
                              future: _firebaseServices.getMyNotifications(
                                  hospital.id, null),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<AppNotification> notifications =
                                      snapshot.data as List<AppNotification>;

                                  if (notifications.isEmpty) {
                                    return SizedBox(
                                        height: 180,
                                        width: double.infinity,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset('images/empty.png',
                                                  height: 110),
                                              const SizedBox(height: 10),
                                              const Text(
                                                "No Notifications",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              )
                                            ]));
                                  }

                                  return ListView.builder(
                                      itemCount: notifications.length,
                                      itemBuilder: (context, ind) {
                                        AppNotification notification =
                                            notifications[ind];

                                        return buildNotifications(notification);
                                      });
                                } else {
                                  return const Center(
                                    child: CustomLoadingWidget(),
                                  );
                                }
                              }),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNotifications(AppNotification notification) {
    return MaterialButton(
      padding: const EdgeInsets.all(0),
      onPressed: () async {
        try {
          // Show loading indicator
          showProgressDialog(context);

          // Handle clerking/report notifications
          if (notification.data['clerkingId'] != null ||
              notification.data['reportId'] != null) {
            final clerkingId = notification.data['clerkingId'] ??
                notification.data['reportId'];
            final clerkingReport =
                await _firebaseServices.getClerkingReportFromId(clerkingId);

            if (!mounted) return;
            Navigator.pop(context); // Dismiss loading

            if (clerkingReport != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClerkingReportDetail(
                    clerkingReport: clerkingReport,
                  ),
                ),
              );
            }
            return;
          }

          if (notification.data['webReferralId'] != null) {
            var webReferralId = notification.data['webReferralId'];
            var webUrl = notification.data['webUrl'];

            if (webUrl != null) {
              try {
                await launchUrl(
                  Uri.parse(webUrl),
                  mode:
                      LaunchMode.externalApplication, // Force external browser
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not open URL: $webUrl'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            if (webReferralId != null) {
              var referral =
                  await _firebaseServices.getReferralFromId(webReferralId);
              // Store the referral data if needed
            }
            return; // Add return to prevent further processing
          }

          // Handle referral notifications
          if (notification.data['referralId'] != null) {
            final referral = await _firebaseServices
                .getReferralFromId(notification.data['referralId']);

            if (!mounted) return;
            Navigator.pop(context); // Dismiss loading

            if (referral != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HospitalsReferralsView(
                    showBack: true,
                  ),
                ),
              );
            }
            return;
          }

          // Handle appointment notifications
          if (notification.type == 'appointment') {
            var appointmentId = notification.data['appointmentId'];
            var centerId = notification.data['centerId'];

            if (appointmentId != null && centerId != null) {
              Appointment? appointment =
                  await _firebaseServices.getAppointmentFromId(appointmentId);
              DiagnosticCenter? center =
                  await _firebaseServices.getCenterFromId(centerId);

              if (!mounted) return;
              Navigator.pop(context); // Dismiss loading

              if (appointment != null && center != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentsScreen(),
                  ),
                );
              }
            }
            return;
          }

          // Handle result notifications
          if (notification.type == 'result') {
            var appointment = await _firebaseServices
                .getAppointmentFromId(notification.data['appointmentId']);

            if (appointment == null) {
              if (!mounted) return;
              Navigator.pop(context);
              return;
            }

            DiagnosticCenter? center =
                await _firebaseServices.getCenterFromId(appointment.centerId);

            if (!mounted) return;
            Navigator.pop(context);

            if (center != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentsScreen(),
                ),
              );
            }
            return;
          }

          // If we get here, dismiss loading
          if (!mounted) return;
          Navigator.pop(context);
        } catch (e) {
          debugPrint('Error handling notification tap: $e');
          if (mounted) {
            Navigator.pop(context); // Dismiss loading
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error opening notification'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: notification.read ? Colors.white : darkGreen,
              child: const Icon(Icons.notification_important),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  notification.message,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 10),
                ),
                const SizedBox(height: 6),
                Text(
                  getTimeAgo(DateTime.parse(notification.timestamp)),
                  style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                      fontSize: 10),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }
}
