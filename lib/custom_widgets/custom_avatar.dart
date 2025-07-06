import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/models/diagnostic_center.dart';
import 'package:pandahealthhospital/models/doctor.dart';
import 'package:pandahealthhospital/models/hospital.dart';
import 'package:pandahealthhospital/models/patient.dart';

class CustomAvatar extends StatelessWidget {
  final dynamic user;
  double radius;

  CustomAvatar(this.user, {this.radius = 25, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: (user is Doctor || user is Patient)
          ? (user.profileUrl.isNotEmpty
              ? NetworkImage(user.profileUrl)
              : const AssetImage("images/profile-img.png") as ImageProvider)
          : user is DiagnosticCenter
              ? (user.centerLogo.isNotEmpty
                  ? NetworkImage(user.centerLogo)
                  : const AssetImage("images/profile-img.png") as ImageProvider)
              : user is Hospital
                  ? (user.centerLogo.isNotEmpty
                      ? NetworkImage(user.centerLogo)
                      : const AssetImage("images/profile-img.png") as ImageProvider)
                  : null,
      // child: (user is Doctor || user is Patient)? (user.profileUrl.isEmpty ?  : null): user is DiagnosticCenter? user.centerLogo.isEmpty ? Image.asset("images/profile-img.png") : null: null
    );
  }
}
