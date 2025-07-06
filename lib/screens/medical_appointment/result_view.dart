import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/body_wrapper.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_loading_widget.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/models/appointment.dart';
import 'package:pandahealthhospital/models/diagnostic_result.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class ResultView extends StatefulWidget {
  const ResultView(this.appointmentId, {super.key});

  final String appointmentId;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final FirebaseServices _firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    final width = getWidth(context);
    final height = getHeight(context);

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const CustomTitleBar(
          title: "Appointment Results",
        ),
        body: Container(
            decoration: backgroundDecoration(false),
            width: width,
            height: height,
            child: SafeArea(
              child: BodyWrapper(
                child: FutureBuilder(
                    future: _firebaseServices
                        .getAppointmentFromId(widget.appointmentId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Appointment? appointment = snapshot.data as Appointment;

                        return ListView.builder(
                            itemCount: appointment.results.length,
                            itemBuilder: (context, ind) {
                              DiagnosticResult result =
                                  appointment.results[ind];

                              return Card(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 30),
                                  child: Column(
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            openLink(result.url);
                                          },
                                          child: const Column(
                                            children: [
                                              Icon(Icons.folder, size: 100),
                                              Text("Tap to view file",
                                                  style: TextStyle(
                                                      color: appPrimaryColor))
                                            ],
                                          )),
                                      const SmallSpace(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Notes: ",
                                              style:
                                                  subheaderTextStyle.copyWith(
                                                      color: appPrimaryColor)),
                                          const SmallSpace(),
                                          Text(result.desc)
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      } else {
                        return const Center(
                          child: CustomLoadingWidget(),
                        );
                      }
                    }),
              ),
            )));
  }
}
