import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/screens/dashboard/custom_app_bar.dart';
import 'package:pandahealthhospital/screens/dashboard/username_widget.dart';
import 'package:pandahealthhospital/screens/drug_interaction/drug_interaction_screen.dart';
import 'package:pandahealthhospital/screens/hospital/hospital_clerking.dart';
import 'package:pandahealthhospital/screens/hospital/qr_code_generator.dart';
import 'package:pandahealthhospital/screens/hospital/view_clerking_reports.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HospitalDashboardView extends StatefulWidget {
  const HospitalDashboardView({super.key});

  @override
  _HospitalDashboardViewState createState() => _HospitalDashboardViewState();
}

class _HospitalDashboardViewState extends State<HospitalDashboardView> {
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);

        print(_sharedFiles.map((f) => f.toMap()));
        if (_sharedFiles.isNotEmpty) {
          handleMedia(_sharedFiles
              .map(
                  (e) => {'name': e.path.split('/').last, 'file': File(e.path)})
              .toList());
        }
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);
        print(_sharedFiles.map((f) => f.toMap()));
        if (_sharedFiles.isNotEmpty) {
          handleMedia(_sharedFiles
              .map(
                  (e) => {'name': e.path.split('/').last, 'file': File(e.path)})
              .toList());
        }

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.instance.reset();
      });
    });
  }

  handleMedia(List<Map<String, dynamic>> receivedFiles) {
    //if it is the hospital app
    if (Provider.of<UserStore>(context, listen: false).hospital != null) {
      if (receivedFiles.isNotEmpty) {
        //So you push the share clerking
        push(HospitalClerkingPage(
          selectedFiles: receivedFiles,
        ));
      }
    } else {
      //Sign Out the user
      showCustomToast("User not found");
      final firebaseServices = FirebaseServices();
      firebaseServices.logout();
    }
  }

  @override
  void dispose() {
    // _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);
    final key = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: key,
      extendBodyBehindAppBar: true,
      appBar: CustomHomeScreenAppBar(
        showBadge: true,
        onTap: () => Scaffold.of(context).openDrawer(),
      ),
      body: Container(
        decoration: backgroundDecoration(true),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultHorizontalPadding,
                    vertical: defaultVerticalPadding,
                  ),
                  child: const Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultHorizontalPadding,
                        ),
                        child: UsernameWidget(),
                      ),
                      SmallSpace(),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Medical Tools",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildFeatureCard(
                              "Patient Clerking Assistant",
                              "Collect patient details, generate AI-powered analysis, and securely share medical records",
                              Icons.medical_services_rounded,
                              () => push(const HospitalClerkingPage()),
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureCard(
                              "Patient Records",
                              "Access and review previous consultations and AI analyses",
                              Icons.folder_shared_rounded,
                              () => push(const ViewClerkingReports()),
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureCard(
                              "Drug Interaction Checker",
                              "Analyze drug interactions with AI-powered assessment and patient context analysis",
                              Icons.medication_liquid_rounded,
                              () => push(const DrugInteractionScreen()),
                              isNew: true,
                            ),
                            const SizedBox(height: 16),
                            /* _buildFeatureCard(
                              "QR Code Generator",
                              "Generate QR codes for quick access to medical records and referrals",
                              Icons.qr_code_rounded,
                              () => push(const QRCodeGenerator()),
                            ), */
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPieChartIndicator(Color color, String text) => Row(children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 2),
        Text(text)
      ]);

  Widget buildLatestVitals(String img, String title, String subtitle) =>
      Material(
        elevation: 0,
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(img, height: 24),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(height: 5, width: 12, color: darkBlue),
                      const SizedBox(width: 2),
                      Container(height: 5, width: 12, color: darkBlue),
                      const SizedBox(width: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildFeatureCard(
    String title, 
    String description, 
    IconData icon, 
    VoidCallback onTap, {
    bool isNew = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: darkBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: darkBlue, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.grey.shade400, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}