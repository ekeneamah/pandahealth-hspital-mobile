import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';

class CustomUserAvatar extends StatelessWidget {
  final double radius;
  final Color backgroundColor;
  final String? profileImg;

  const CustomUserAvatar(
      {super.key,
      this.backgroundColor = actualLightGreen,
      this.radius = 50,
      this.profileImg});

  @override
  Widget build(BuildContext context) {
    var useRadius = radius;
    //If the radius is less than 20 make it 20
    if (radius < 20) {
      useRadius = 20;
    }

    // TODO: implement build
    return CircleAvatar(
        radius: radius + 5,
        backgroundColor: backgroundColor,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          backgroundImage:
              profileImg == null ? null : NetworkImage(profileImg!),
          child: profileImg == null ? Icon(Icons.person) : Container(),
        ));
  }
}

class CustomProfileAvatar extends StatelessWidget {
  final double radius;
  final Color backgroundColor;
  final String? profileImg;

  const CustomProfileAvatar(
      {super.key,
      this.backgroundColor = Colors.white,
      this.radius = 20,
      this.profileImg});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: profileImg == null ? null : NetworkImage(profileImg!),
      child: profileImg == null ? Icon(Icons.person) : Container(),
    );
  }
}
