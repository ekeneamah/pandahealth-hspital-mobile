import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_avatar.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/custom_widgets/user_avatar.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/hospital.dart';
import 'package:pandahealthhospital/models/patient.dart';

import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/app_functions.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:provider/provider.dart';

class HospitalSettingsView extends StatefulWidget {
  const HospitalSettingsView({super.key});

  @override
  State<HospitalSettingsView> createState() => _HospitalSettingsViewState();
}

class _HospitalSettingsViewState extends State<HospitalSettingsView> {
  ScrollController scrollController = ScrollController();

  bool setBackgroundColor = false;

  final FirebaseServices _firebaseServices = FirebaseServices();
  late Hospital hospital;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrollController.addListener(() {
      //If the page scrolls past a certain level give it a background color
      if (scrollController.offset > 10) {
        setState(() {
          setBackgroundColor = true;
        });
      } else {
        setState(() {
          setBackgroundColor = false;
        });
      }
    });
  }

  Future getImage() async {
    final pickedFile =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (pickedFile != null) {
      String filePath = pickedFile.files.single.path!;
      var image = File(filePath);
      showProgressDialog(context);
      var imgUrl =
          await _firebaseServices.uploadFilesToFirebaseStorage([image]);
      //Dismiss the dialog
      Navigator.of(context).pop();
      if (imgUrl.isNotEmpty) {
        String imageUrl = imgUrl.first;
        _firebaseServices
            .updateProfileInfo(context, hospital.id, {'profileUrl': imageUrl});
      }
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = getScreenHeight(context);
    final width = getScreenWidth(context);

    final myId = Provider.of<UserStore>(context, listen: false).doctor?.id;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomTitleBar(
          backgroundColor:
              setBackgroundColor ? actualLightGreen : Colors.transparent),
      body: Consumer<UserStore>(builder: (context, store, child) {
        hospital = store.hospital!;

        return SingleChildScrollView(
          controller: scrollController,
          child: Stack(
            children: [
              Container(
                width: width,
                height: height * 0.2,
                decoration: const BoxDecoration(
                    color: actualLightGreen,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
              ),
              Container(
                width: width,
                padding: const EdgeInsets.symmetric(
                    vertical: defaultVerticalPadding,
                    horizontal: defaultHorizontalPadding),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SmallSpace(),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          children: [
                            CustomAvatar(
                              hospital,
                              radius: 50,
                            ),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt),
                                  onPressed: () {
                                    getImage();
                                  },
                                ))
                          ],
                        ),
                      ),
                      const SmallSpace(),
                      Text(
                        hospital.name,
                        style: const TextStyle(fontSize: 18, color: actualDarkGreen),
                      ),
                      const MediumSpace(),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: defaultVerticalPadding,
                              horizontal: defaultHorizontalPadding),
                          child: Column(
                            children: [
                              Container(
                                width: width,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 25),
                                decoration: BoxDecoration(
                                    color: cardBackgroundColor,
                                    borderRadius: BorderRadius.circular(25)),
                                child: const Text(
                                  "Your Data",
                                  style: labelHeaderTextStyle,
                                ),
                              ),
                              const SmallSpace(),
                              ListTile(
                                // onTap: ()=> push(const ChangePersonalInformation()),
                                title: const Text(
                                  "Phone No.",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(hospital.phoneNumber),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    // Icon(Icons.arrow_forward_ios)
                                  ],
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                // onTap: ()=> push(const ChangePersonalInformation()),
                                title: const Text(
                                  "Email",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(hospital.email),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    // Icon(Icons.arrow_forward_ios)
                                  ],
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                // onTap: () => push(const ChangeAddress()),
                                title: const Text(
                                  "Address",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                        width: width * 0.45,
                                        child: Text(hospital.address.isEmpty
                                            ? "Enter your address here"
                                            : hospital.address)),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    // Icon(Icons.arrow_forward_ios)
                                  ],
                                ),
                              ),
                              const Divider(),

                              const Divider(),
                              const SmallSpace(),
                              Container(
                                width: width,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 25),
                                decoration: BoxDecoration(
                                    color: cardBackgroundColor,
                                    borderRadius: BorderRadius.circular(25)),
                                child: const Text(
                                  "Security",
                                  style: TextStyle(
                                      fontSize: 18, color: actualDarkGreen),
                                ),
                              ),
                              const SmallSpace(),
                              ListTile(
                                onTap: () async {
                                  bool confirm = await showInfoConfirmationAlert(
                                      "Confirm",
                                      "A password reset link will be sent to your email ${hospital.email}",
                                      context);
                                  if (confirm) {
                                    bool res = await _firebaseServices
                                        .resetPassword(hospital.email);
                                    if (res) {
                                      showCustomToast(
                                          "Password reset email sent to ${hospital.email}");
                                    } else {
                                      showCustomErrorToast(
                                          "Coudn't reset password");
                                    }
                                  }
                                },
                                title: const Text(
                                  "Change Password",
                                ),
                                trailing: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Icon(Icons.arrow_forward_ios)],
                                ),
                              ),
                              const Divider(),

                              const MediumSpace(),
                              ListTile(
                                onTap: () async {
                                  bool confirm = await showInfoConfirmationAlert(
                                      "Confirm",
                                      "Are your sure you want to delete your account. This action cannot be undone",
                                      context);
                                  if (confirm) {
                                    if (myId != null) {
                                      bool response = await _firebaseServices
                                          .deleteAccount(myId);
                                      if (response) {
                                        _firebaseServices.logout();
                                        Navigator.popUntil(
                                            context, (route) => route.isFirst);
                                      }
                                    }
                                  }
                                },
                                title: const Text(
                                  "Delete your account",
                                  style: TextStyle(color: Colors.red),
                                ),
                                trailing: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.delete, color: Colors.red)
                                  ],
                                ),
                              ),
                              // ListTile(
                              //   onTap: () => push(const ChangePasscodeView()),
                              //   title: Text(
                              //     "Change Passcode",
                              //   ),
                              //   trailing: Row(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [Icon(Icons.arrow_forward_ios)],
                              //   ),
                              // ),
                              // const Divider(),
                              // Container(
                              //   width: width,
                              //   padding: const EdgeInsets.symmetric(
                              //       vertical: 15, horizontal: 25),
                              //   decoration: BoxDecoration(
                              //       color: cardBackgroundColor,
                              //       borderRadius: BorderRadius.circular(25)),
                              //   child: Text(
                              //     "Extra",
                              //     style: TextStyle(
                              //         fontSize: 18, color: actualDarkGreen),
                              //   ),
                              // ),
                              // const SmallSpace(),
                              // ListTile(
                              //   onTap: () => push(const ChangeUnits()),
                              //   title: const Text(
                              //     "Unit",
                              //   ),
                              //   trailing: const Row(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [
                              //       Text("Imperial"),
                              //       Icon(Icons.arrow_forward_ios)
                              //     ],
                              //   ),
                              // ),
                              // const Divider(),
                              // ListTile(
                              //   onTap: () => push(const ChangeBloodType()),
                              //   title: Text(
                              //     "Blood Type",
                              //   ),
                              //   trailing: Row(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [Icon(Icons.arrow_forward_ios)],
                              //   ),
                              // ),
                              // const Divider(),
                              // ListTile(
                              //   onTap: () =>
                              //       push(const ChangePrimaryHealthcareGiver()),
                              //   title: const Text(
                              //     "Primary Care Physician",
                              //   ),
                              //   trailing: const Row(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [Icon(Icons.arrow_forward_ios)],
                              //   ),
                              // ),
                              // const Divider(),
                              // const ListTile(
                              //   title: Text(
                              //     "Emergency Information",
                              //   ),
                              //   trailing: Row(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [Icon(Icons.arrow_forward_ios)],
                              //   ),
                              // ),
                              // const Divider(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
