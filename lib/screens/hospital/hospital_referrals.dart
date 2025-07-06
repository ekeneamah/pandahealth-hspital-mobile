import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/button_loader.dart';
import 'package:pandahealthhospital/custom_widgets/buttons.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_avatar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/custom_widgets/custom_loading_widget.dart';
import 'package:pandahealthhospital/custom_widgets/custom_textfield.dart';
import 'package:pandahealthhospital/custom_widgets/no_referrals_widget.dart';
import 'package:pandahealthhospital/custom_widgets/skeleton_list_tile.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/custom_widgets/user_avatar.dart';
import 'package:pandahealthhospital/models/appointment.dart';
import 'package:pandahealthhospital/models/chat.dart';
import 'package:pandahealthhospital/models/diagnostic_center.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/patient.dart';
import 'package:pandahealthhospital/models/referral.dart';
import 'package:pandahealthhospital/screens/connect/chat.dart';
import 'package:pandahealthhospital/screens/hospital/select_hospital_doctor.dart';
// import 'package:pandahealthhospital/screens/medical_appointment/appointment_results.dart';
// import 'package:pandahealthhospital/screens/medical_appointment/create_referral.dart';
// import 'package:pandahealthhospital/screens/referrals/diagnostic_center_view.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/app_functions.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:provider/provider.dart';

class HospitalsReferralsView extends StatefulWidget {
  final bool showBack;

  const HospitalsReferralsView({this.showBack = false, super.key});

  @override
  State<HospitalsReferralsView> createState() => _HospitalsReferralsViewState();
}

class _HospitalsReferralsViewState extends State<HospitalsReferralsView> {
  final searchCtrl = TextEditingController();

  final FirebaseServices _firebaseServices = FirebaseServices();

  late var myUser;

  List<Referral> referrals = [];

  bool loading = false;
  String searchQuery = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    myUser = Provider.of<UserStore>(context, listen: false).hospital;

    searchCtrl.addListener(() {
      setState(() {
        searchQuery = searchCtrl.text;
      });
    });
  }

  bool filterReferral(Referral referral, String query, Patient? patient) {
    final searchQuery = query.toLowerCase();

    // Search by patient phone
    if (referral.patientPhone.toLowerCase().contains(searchQuery)) {
      return true;
    }

    // Search by patient name if patient exists
    if (patient != null) {
      final patientFullName =
          '${patient.firstName} ${patient.lastName}'.toLowerCase();
      if (patientFullName.contains(searchQuery)) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.showBack);

    final width = getScreenWidth(context);

    final height = getScreenHeight(context);

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomTitleBar(
          title: 'Healthcare Centre Referrals',
          showBackButton: widget.showBack,
        ),
        body: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(vertical: defaultVerticalPadding),
          decoration: backgroundDecoration(false),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        //ToDo: Replace with the actual asset
                        SizedBox(
                            width: 70,
                            child: Image.asset(
                                "images/primary_healthcare_specialist.png"))
                    // Image.asset("", height: 100),
                    ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      labelText: 'Search Referrals by Patient Name or Phone',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const MediumSpace(),

                Expanded(
                  child: FutureBuilder<List<Referral>>(
                      future: _firebaseServices.getHospitalsReferrals(
                          myUser.id, null),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CustomLoadingWidget());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: NoReferralsWidget(
                              text: 'You have no referrals yet',
                            ),
                          );
                        }

                        List<Referral> referrals = snapshot.data!;
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: referrals.length,
                            itemBuilder: (context, ind) {
                              Referral referral = referrals[ind];

                              return FutureBuilder<Patient?>(
                                  future: _firebaseServices
                                      .getPatientFromId(referral.patientPhone),
                                  builder: (context, patientSnapshot) {
                                    Patient? patient = patientSnapshot.data;

                                    if (searchQuery.isNotEmpty &&
                                        patient != null) {
                                      final query = searchQuery.toLowerCase();
                                      final patientFullName =
                                          '${patient.firstName} ${patient.lastName}'
                                              .toLowerCase();
                                      final patientPhone =
                                          referral.patientPhone.toLowerCase();

                                      if (!patientFullName.contains(query) &&
                                          !patientPhone.contains(query)) {
                                        return const SizedBox.shrink();
                                      }
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(15),
                                        elevation: 4,
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text("Referred: "),
                                                  Text(dateFormatter(
                                                      DateTime.parse(referral
                                                          .creationDate)))
                                                ],
                                              ),
                                              const SmallSpace(),
                                              if (patientSnapshot.hasData &&
                                                  patient != null)
                                                ListTile(
                                                    trailing: IconButton(
                                                        onPressed: () async {
                                                          showProgressDialog(
                                                              context);
                                                          Chat? chat =
                                                              await _firebaseServices
                                                                  .getChatFromId(
                                                                      [
                                                                myUser.id,
                                                                patient.id
                                                              ],
                                                                      [
                                                                myUser.userType,
                                                                patient.userType
                                                              ]);
                                                          Navigator.of(context)
                                                              .pop();
                                                          if (chat != null) {
                                                            push(ChatScreen(
                                                                chat, patient));
                                                          }
                                                        },
                                                        icon: const Icon(Icons.chat,
                                                            color: lightGreen)),
                                                    leading:
                                                        CustomAvatar(patient),
                                                    title: Text(
                                                      '${patient.firstName} ${patient.lastName}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Row(
                                                          children: [
                                                            Icon(Icons.person,
                                                                color:
                                                                    lightGreen,
                                                                size: 17),
                                                            Text('Doctor'),
                                                          ],
                                                        ),
                                                        FutureBuilder(
                                                            future: _firebaseServices
                                                                .checkIfAccessRequested(
                                                                    myUser.id,
                                                                    patient.id),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                bool
                                                                    accessRequested =
                                                                    snapshot.data
                                                                        as bool;
                                                                if (accessRequested) {
                                                                  return Container();
                                                                } else {
                                                                  return buildButton(
                                                                      'Request Access',
                                                                      Icons
                                                                          .send,
                                                                      () {
                                                                    _firebaseServices.requestAccessFromPatient(
                                                                        myUser
                                                                            .id,
                                                                        patient
                                                                            .id);
                                                                  }, lightGreen);
                                                                }
                                                              } else {
                                                                return Container();
                                                              }
                                                            }),
                                                      ],
                                                    ))
                                              else
                                                ListTile(
                                                  leading:
                                                      CustomProfileAvatar(),
                                                  subtitle: const Text(
                                                      "Unregistered Patient"),
                                                  title: Text(
                                                    referral.patientPhone,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              const Text("Doctor"),
                                              const SmallSpace(),
                                              FutureBuilder(
                                                  future: _firebaseServices
                                                      .getDoctorFromId(
                                                          referral.doctorId),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      Doctor doctor = snapshot
                                                          .data as Doctor;
                                                      return ListTile(
                                                          trailing: InkWell(
                                                              onTap: () async {
                                                                Doctor?
                                                                    newDoctor =
                                                                    await push(SelectHospitalDoctor(
                                                                        selectedDoctor:
                                                                            doctor));
                                                                if (newDoctor !=
                                                                    null) {
                                                                  showProgressDialog(
                                                                      context);
                                                                  await _firebaseServices
                                                                      .updateReferralData(
                                                                          referral
                                                                              .id,
                                                                          {
                                                                        'doctorId':
                                                                            newDoctor.id
                                                                      });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  showCustomToast(
                                                                      "Updated Successfully");
                                                                  setState(
                                                                      () {});
                                                                }
                                                              },
                                                              child: const Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        3.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Icon(Icons
                                                                        .refresh),
                                                                    SizedBox(
                                                                        width:
                                                                            5),
                                                                    Text(
                                                                        "Swap Doctor")
                                                                  ],
                                                                ),
                                                              )),
                                                          leading: CustomAvatar(
                                                              doctor),
                                                          title: Text(
                                                            '${doctor.firstName} ${doctor.lastName}',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16),
                                                          ),
                                                          subtitle: const Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .person,
                                                                      color:
                                                                          lightGreen,
                                                                      size: 17),
                                                                  Text(
                                                                      'Doctor'),
                                                                ],
                                                              ),
                                                            ],
                                                          ));
                                                    } else {
                                                      return ListTile(
                                                        leading:
                                                            CustomProfileAvatar(),
                                                        subtitle: const Text(
                                                            "Unregistered Patient"),
                                                        title: Text(
                                                          referral.patientPhone,
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                        ),
                                                      );
                                                    }
                                                  }),
                                              const SmallSpace(),
                                              const Divider(),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'Test:',
                                                style: TextStyle(
                                                    color: lightGreen,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 8),
                                              Column(
                                                  children: referral.tests
                                                      .map((e) => ListTile(
                                                            title: Text(e.name),
                                                            subtitle: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    formatCurrency(
                                                                        e.price,
                                                                        "NGN")),
                                                                const SmallSpace(),
                                                                const Text(
                                                                    "Recommended Center"),
                                                                FutureBuilder(
                                                                    future: _firebaseServices
                                                                        .getCenterFromId(e
                                                                            .centerId),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (snapshot
                                                                          .hasData) {
                                                                        DiagnosticCenter
                                                                            center =
                                                                            snapshot.data
                                                                                as DiagnosticCenter;

                                                                        return Column(
                                                                          children: [
                                                                            ListTile(
                                                                              leading: CustomAvatar(center),
                                                                              title: Text(center.name),
                                                                              subtitle: SizedBox(
                                                                                  width: width * 0.5,
                                                                                  child: Text(
                                                                                    center.address,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  )),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      } else {
                                                                        return const SkeletonListTile();
                                                                      }
                                                                    })
                                                              ],
                                                            ),
                                                          ))
                                                      .toList()),
                                              const SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            });
                      }),
                )
                // ref.watch(referralsProvider(searchCtrl.text.trim())).when(
                //     data: (data) => data.isEmpty
                //         ? Expanded(
                //             child: const Center(
                //               child: NoHospitalsReferralsWidget(
                //                 text: 'You have no referrals yet',
                //               ),
                //             ),
                //           )
                //         : Column(
                //             children: data
                //                 .map((e) => Padding(
                //                       padding: const EdgeInsets.all(16.0),
                //                       child: Material(
                //                         borderRadius: BorderRadius.circular(15),
                //                         elevation: 4,
                //                         color: Colors.white,
                //                         child: Padding(
                //                           padding: const EdgeInsets.all(16.0),
                //                           child: Column(
                //                             crossAxisAlignment:
                //                                 CrossAxisAlignment.start,
                //                             children: [
                //                               Row(
                //                                 children: [
                //                                   const CircleAvatar(
                //                                       radius: 25),
                //                                   const SizedBox(width: 18),
                //                                   Column(
                //                                     crossAxisAlignment:
                //                                         CrossAxisAlignment
                //                                             .start,
                //                                     children: [
                //                                       Padding(
                //                                         padding:
                //                                             const EdgeInsets
                //                                                 .only(left: 6),
                //                                         child: Text(
                //                                           "${e.physician!.firstName!} ${e.physician!.lastName!}",
                //                                           style:
                //                                               const TextStyle(
                //                                                   fontWeight:
                //                                                       FontWeight
                //                                                           .bold,
                //                                                   fontSize: 16),
                //                                         ),
                //                                       ),
                //                                       Row(
                //                                         children: [
                //                                           const Icon(
                //                                               Icons.person,
                //                                               color: lightGreen,
                //                                               size: 17),
                //                                           const Text('Doctor'),
                //                                           const SizedBox(
                //                                               width: 15),
                //                                           Text(
                //                                               'Sex: ${e.physician!.gender}')
                //                                         ],
                //                                       ),
                //                                       Row(
                //                                         children: [
                //                                           Icon(Icons.place,
                //                                               color: lightGreen,
                //                                               size: 17),
                //                                           const Text(
                //                                               'Lekki Phase 1, Lagos, Nigeria'),
                //                                         ],
                //                                       ),
                //                                     ],
                //                                   )
                //                                 ],
                //                               ),
                //                               const Divider(),
                //                               const SizedBox(height: 8),
                //                               const Text(
                //                                 'Test:',
                //                                 style: TextStyle(
                //                                     color: lightGreen,
                //                                     fontWeight: FontWeight.bold,
                //                                     fontSize: 16),
                //                               ),
                //                               const SizedBox(height: 8),
                //                               Column(
                //                                   children: List.generate(
                //                                       e.tests.length, (i) {
                //                                 final tests =
                //                                     e.tests[i].test!.test;
                //
                //                                 return Text("$tests");
                //                               })),
                //                               const SizedBox(height: 20),
                //                               buildButton(
                //                                   'View',
                //                                   Icons.visibility,
                //                                   () => push(
                //                                       DiagnosticCenterView(
                //                                           id: e.id!)),
                //                                   lightGreen)
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ))
                //                 .toList()),
                //     error: (e, _) => Center(
                //         child: PandaErrorWidget(() => ref.refresh(
                //             referralsProvider(searchCtrl.text.trim())))),
                //     loading: () => const Expanded(
                //           child: Center(
                //             child: CircularProgressIndicator(),
                //           ),
                //         ))
              ],
            ),
          ),
        ));
  }

  Widget buildButton(
          String text, IconData icon, VoidCallback onTap, Color color) =>
      CustomButton(
        onPressed: onTap,
        radius: 22,
        height: 48,
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: Colors.white)
          ],
        ),
      );
}
