import 'dart:async';
import 'dart:convert';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/screens/hospital/hospital_appointments.dart';
import 'package:pandahealthhospital/screens/connect/chats.dart';
import 'package:pandahealthhospital/screens/hospital/hospital_dashboard.dart';
import 'package:pandahealthhospital/screens/hospital/hospital_doctors.dart';
import 'package:pandahealthhospital/screens/hospital/hospital_referrals.dart';
import 'package:pandahealthhospital/screens/profile/hospital_profile_menu_view.dart';
import 'package:pandahealthhospital/screens/hospital/view_clerking_report.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:provider/provider.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int activeIndex = 0;
  final doctorScreens = [
    // const DashboardView(),
    // const ReferralsView(showBack: false,),
    // const AppointmentsView(),
    // const ChatsScreen(),
  ];

  final hospitalScreens = [
    const HospitalDashboardView(),
    const HospitalsReferralsView(),
    DoctorsScreen(),
    const AppointmentsScreen(),
  ];

  final icons = [
    'images/icon-home.png',
    'images/icon-chemistry.png',
    // 'images/icon-date.png',
    'images/icon-date.png',
    'images/appointments_design.png',
  ];
  final text = ['Home', 'Referrals', 'Connect', 'Appointments'];

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseServices _firebaseServices = FirebaseServices();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle when notification is tapped in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundTap);

        // Check if app was opened from a notification
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleInitialMessage(initialMessage);
        }
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
        if (details.payload != null) {
          final data = jsonDecode(details.payload!);
          _handleNotificationNavigation(data);
        }
      },
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            channelDescription: 'Default notification channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleBackgroundTap(RemoteMessage message) {
    debugPrint('Notification tapped in background: ${message.messageId}');
    _handleNotificationNavigation(message.data);
  }

  void _handleInitialMessage(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.messageId}');
    _handleNotificationNavigation(message.data);
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) async {
    try {
      if (data['clerkingId'] != null) {
        if (!mounted) return;
        showLoadingDialog(context);

        final clerkingReport =
            await _firebaseServices.getClerkingReportFromId(data['clerkingId']);

        if (!mounted) return;
        Navigator.pop(context);

        if (clerkingReport != null) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClerkingReportDetail(
                clerkingReport: clerkingReport,
              ),
            ),
          );
          return;
        }
      }

      // Handle other notification types
      final notificationType = data['type'];
      switch (notificationType) {
        case 'chat':
          setState(() => activeIndex = 2); // Switch to chat tab
          break;
        case 'appointment':
          setState(() => activeIndex = 1); // Switch to appointments tab
          break;
        case 'doctor':
          setState(() => activeIndex = 3); // Switch to doctors tab
          break;
      }
    } catch (e) {
      debugPrint('Error handling notification navigation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening notification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(appPrimaryColor),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserStore>(builder: (context, store, child) {
      final icons = [
        'images/icon-home.png',
        'images/icon-chemistry.png',
        'images/doctor.png',
        'images/appointments_design.png',
      ];
      final text = [
        'Home',
        'Referrals',
        "Doctors",
        'Appointments',
      ];

      return Scaffold(
        drawer: const HospitalProfileMenuView(),
        body: hospitalScreens[activeIndex],
        // floatingActionButton: InkWell(
        //   onTap: (){
        //     showPopUpDialog(context, Column(
        //       children: [
        //         const Text("Add New", style: headerTextStyle,),
        //         const SmallSpace(),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: ListTile(
        //             onTap: (){
        //               Navigator.of(context).pop();
        //               push(SelectPractitionerGroup());
        //             },
        //             leading: Image.asset(iconAssets['appointments']!),
        //             title: Text("Appointment(s)"),
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: ListTile(
        //             onTap: (){
        //               Navigator.of(context).pop();
        //               push(const MedicalRecordsView());
        //             },
        //             leading: Image.asset(iconAssets['vitals']!),
        //             title: Text("Vital(s)"),
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: ListTile(
        //             onTap: (){
        //               Navigator.of(context).pop();
        //               push(const HealthCareProvidersView());
        //             },
        //             leading: Image.asset(iconAssets['healthcare']!),
        //             title: Text("Healthcare Provider(s)"),
        //           ),
        //         ),
        //       ],
        //     ));
        //   },
        //   child: Container(
        //       height: 65,
        //       width: 65,
        //       decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(50),
        //           gradient: const LinearGradient(colors: [lightGreen, darkGreen])),
        //       child: const Icon(Icons.add, size: 40, color: Colors.white)),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            height: 65,
            itemCount: icons.length,
            gapWidth: 0,
            tabBuilder: ((index, isActive) {
              final color = isActive ? darkBlue : Colors.green.shade200;
              final size = isActive ? 9.0 : 8.0;

              return Column(children: [
                const SizedBox(height: 8),
                Image.asset(icons[index], height: 25, color: color),
                Text(
                  text[index],
                  style: TextStyle(
                      fontSize: size,
                      color: color,
                      fontWeight: FontWeight.bold),
                )
              ]);
            }),
            activeIndex: activeIndex,
            // gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.defaultEdge,
            onTap: (i) => setState(() => activeIndex = i)),
      );
    });
  }
}
