import 'package:flutter/material.dart';

class CustomLoadingWidget extends StatelessWidget{
  const CustomLoadingWidget({super.key});


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.black),);

  }
}