import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_avatar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/screens/hospital/hospital_settings.dart';
import 'package:pandahealthhospital/screens/support/support_screen.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:provider/provider.dart';

class HospitalProfileMenuView extends StatelessWidget {
  const HospitalProfileMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);

    return Drawer(
      shape: const OutlineInputBorder(
        borderSide: BorderSide.none,
        // borderRadius: BorderRadius.only(topRight: Radius.circular(30))
      ),
      child: Consumer<UserStore>(builder: (context, store, child) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(
                            colors: [lightGreen.withOpacity(0.8), lightGreen])),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: CustomAvatar(
                              store.hospital,
                              radius: 40,
                            ),
                          ),
                          const SmallSpace(),
                          Text(
                            '${store.hospital?.name}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: Colors.white),
                          ),
                          Text(
                            '${store.hospital?.phoneNumber}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          // const SizedBox(height: 20),
                          // const Padding(
                          //   padding: EdgeInsets.symmetric(vertical: 1.0),
                          //   child: Text(
                          //     '22%',
                          //     style: TextStyle(
                          //         fontWeight: FontWeight.w600,
                          //         color: Colors.white),
                          //   ),
                          // ),
                          // Container(
                          //   height: 15,
                          //   padding: const EdgeInsets.all(4),
                          //   alignment: Alignment.centerLeft,
                          //   width: double.infinity,
                          //   decoration: BoxDecoration(
                          //       color: const Color(0xff59b686),
                          //       borderRadius: BorderRadius.circular(80)),
                          //   child: Container(
                          //     height: 5,
                          //     width: 50,
                          //     decoration: BoxDecoration(
                          //         color: Colors.white,
                          //         borderRadius: BorderRadius.circular(80)),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // buildListTile(
                          //     'images/healthcare.png',
                          //     'My Doctors',
                          //     () => push(HealthCareProvidersView())),
                          // buildListTile(
                          //     'images/icon-chemistry.png',
                          //     'Medical records',
                          //     () => push(const MedicalRecordsView())),
                          // buildListTile('images/padlock.png', 'Access Manager',
                          //     () => push( AccessManagerView())),
                          buildListTile('images/user.png', 'Contact Support',
                              () => push(const ContactSupportView())),
                          buildListTile('images/setting.png', 'Settings',
                              () => push(const HospitalSettingsView())),
                          buildListTile('images/logout.png', 'Logout',
                              () async {
                            //Show Logout Popup
                            var confirm = await showInfoConfirmationAlert(
                                "Logout",
                                "Are you sure you want to logout?",
                                context);
                            if (confirm) {
                              FirebaseServices firebaseServices =
                                  FirebaseServices();
                              var done = await firebaseServices.logout();
                              if (done) {
                                // Clear the navigation stack and go to welcome screen
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/',
                                  (Route<dynamic> route) => false,
                                );
                                // Or alternatively:
                                // Navigator.of(context).pushAndRemoveUntil(
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //           const WelcomeScreen()),
                                //   (route) => false,
                                // );
                              } else {
                                showCustomErrorToast("Couldn't Log Out");
                              }
                            }
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget buildListTile(String img, String title, VoidCallback onTap) =>
      ListTile(
          onTap: onTap,
          leading: Image.asset(img, height: 25, color: lightGreen, width: 22),
          title: Text(title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.keyboard_arrow_right));
}
