//Navigation

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/spaces.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';

import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
// import 'package:url_launcher/url_launcher.dart';

navigateToScreen(BuildContext context, Widget widget) async {
  var response = await Navigator.of(context)
      .push(CupertinoPageRoute(builder: (context) => widget));
  return response;
}

navigateToScreenMaterial(BuildContext context, Widget widget) async {
  var response = await Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => widget));
  return response;
}

navigateToScreenModal(BuildContext context, Widget widget) async {
  var response = await Navigator.of(context).push(
      MaterialPageRoute(fullscreenDialog: true, builder: (context) => widget));
  return response;
}

navigateToScreenOpaque(BuildContext context, Widget widget) async {
  var response = await Navigator.of(context).push(
    PageRouteBuilder(
        opaque: false, // set to false
        pageBuilder: (_, __, ___) => widget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        }),
  );

  return response;
}

showProgressDialog(BuildContext context) {
  AlertDialog alert = const AlertDialog(
    backgroundColor: Colors.white,
    content: SizedBox(
        width: 30,
        height: 100,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(appPrimaryColor),
            ),
            SmallSpace(),
            Text(
              "Loading...",
              style: TextStyle(color: darkGreen),
            )
          ],
        ))),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return SizedBox(width: 30, height: 30, child: alert);
    },
  );
}

//This functions remove the current page from the stack and replace it with the new page
replaceScreen(BuildContext context, Widget widget) async {
  Navigator.of(context).pop();
  var response = await Navigator.of(context)
      .push(CupertinoPageRoute(builder: (context) => widget));
  return response;
}

replaceScreenMaterial(BuildContext context, Widget widget) async {
  Navigator.of(context).pop();
  var response = await Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => widget));
  return response;
}

replaceScreenModal(BuildContext context, Widget widget) async {
  Navigator.of(context).pop();
  var response = await Navigator.of(context).push(
      MaterialPageRoute(fullscreenDialog: true, builder: (context) => widget));
  return response;
}

String? getMyId(BuildContext context) {
  var provider = Provider.of<UserStore>(context, listen: false);
  print(provider.doctor?.toMap());
  return provider.doctor?.id;
}

// goToLink(String url) async {
//   try {
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url));
//
//     } else {
//       showCustomToast("Oops!. Something went wrong. Check your network");
//     }
//   } catch (er) {
//     print(er);
//   }
// }

Future<DateTime?> selectDate(
    BuildContext context, DateTime? selectedDate) async {
  selectedDate ??= DateTime.now();

  DateTime? picked;

  if (Platform.isAndroid) {
    picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: appPrimaryColor,
                onPrimary: Colors.black,
                onSurface: appPrimaryColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1900),
        lastDate: DateTime(DateTime.now().year - 8));
  } else {
    await showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
              color: Colors.black,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: selectedDate,
                              maximumDate: DateTime(DateTime.now().year - 8),
                              onDateTimeChanged: (val) {
                                picked = val;
                              }),
                        ),
                        CupertinoButton(
                          child: const Text('Done'),
                          onPressed: () {
                            Navigator.pop(context); // Dismiss the modal popup
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
  }

  if (picked != null) {
    selectedDate = picked;
    return selectedDate;
  }
  return null;
}
