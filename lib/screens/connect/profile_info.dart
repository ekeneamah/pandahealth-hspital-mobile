import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/custom_widgets/user_avatar.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/patient.dart';
import 'package:pandahealthhospital/utils/utils.dart';

class ProfileInfo extends StatefulWidget {
  final Object user;

  const ProfileInfo(this.user, {super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  late var user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);
    final height = getScreenHeight(context);

    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: const Text("Profile Info", style: TextStyle(color: Colors.black)),
            centerTitle: false,
            backgroundColor: actualLightGreen,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black))),
        body: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(
              vertical: defaultVerticalPadding,
              horizontal: defaultHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.3,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CustomUserAvatar(),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.person),
                            )))
                  ],
                ),
              ),
              const SmallSpace(),
              Text(
                user is Doctor || user is Patient
                    ? "${user?.firstName} ${user.lastName}"
                    : "${user.name}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SmallSpace(),
              const Text("PATIENT"),
              const SmallSpace(),
              // Divider(),
              // Container(
              //   width: width,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text("Files", style: TextStyle(fontSize: 18, color: actualDarkGreen, fontWeight: FontWeight.w700),),
              //       const SmallSpace(),
              //       ListTile(
              //         leading: Image.asset("images/pdf_icon.png", width: 40),
              //         title: Text("Time schedule 2022"),
              //         trailing: Icon(Icons.download, size: 30, color: actualDarkGreen),
              //       ),
              //       ListTile(
              //         leading: Image.asset("images/pdf_icon.png", width: 40),
              //         title: Text("Time schedule 2022"),
              //         trailing: Icon(Icons.download, size: 30, color: actualDarkGreen),
              //       ),
              //       ListTile(
              //         leading: Image.asset("images/pdf_icon.png", width: 40),
              //         title: Text("Time schedule 2022"),
              //         trailing: Icon(Icons.download, size: 30, color: actualDarkGreen),
              //       ),
              //     ],
              //   ),
              // ),
              // Divider(),
              // ListTile(
              //   leading: Icon(Icons.people_alt_outlined, color: actualDarkGreen),
              //   title: Text("Connect User with a physician", style: TextStyle(color: actualDarkGreen))
              // ),
              // ListTile(
              //     leading: Icon(Icons.block, color: Colors.red),
              //     title: Text("Block this user", style: TextStyle(color: Colors.red))
              // ),
              // ListTile(
              //     leading: Icon(Icons.clear, color: Colors.red),
              //     title: Text("Clear", style: TextStyle(color: Colors.red))
              // ),
            ],
          ),
        ));
  }
}
