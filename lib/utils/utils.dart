import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

//Utility Functions
Future<File?> pickFile(
    {List<String>? allowedExtensions = const [
      'jpg',
      'jpeg',
      'png',
      'pdf'
    ]}) async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: allowedExtensions);

  if (result != null) {
    if (result.files.single.path == null) return null;
    File file = File(result.files.single.path!);
    return file;
  } else {
    // User canceled the picker
    showCustomErrorToast("No File Picked");
    return null;
  }
}

// import 'package:flash/flash.dart';
// import 'package:flash/flash_helper.dart';

final navigatorKey = GlobalKey<NavigatorState>();

List<String> removeFirstInstance(List<String> list, String value) {
  int index = list.indexOf(value);

  if (index != -1) {
    list.removeAt(index);
  }

  return list;
}

String getTimeAgo(DateTime date) {
  return timeago.format(date);
}

String getRandomHealthPositiveMessage() {
  final healthPositiveMessages = [
    "Your well-being is important, and we're here to support you.",
    "Connecting patients with the care they need is our mission.",
    "Every step you take towards better health is a victory.",
    "Together, we're improving healthcare access for everyone.",
    "Thank you for being a part of our health and wellness community.",
    "You're making positive choices for your health every day.",
    "Every health goal you achieve brings us closer to a healthier world.",
    "Compassion and self-care drive our commitment to your well-being.",
    "Your health journey is a step towards a better quality of life.",
    "We believe in the power of personal health decisions to transform lives.",
    "Keep prioritizing your health and well-being every day.",
    "Health is a journey, and you're a valued participant in your own care.",
    "Your commitment to your well-being inspires those around you.",
    "Your choices contribute to a healthier and happier life.",
    "Empowering yourself to prioritize health is our shared goal.",
    "Together, we're shaping a future of well-being and vitality.",
    "Your commitment to your health is the heartbeat of our community.",
    "We're grateful for your dedication to living a healthy life.",
    "Making choices for your health means offering hope and resilience.",
    "You're part of a community that cares about your well-being.",
    "Every healthy choice you make is a step towards a better life.",
    "Your commitment to your health is changing lives for the better.",
    "Thank you for being a health and wellness hero in your own journey.",
    "Living a healthy life is more than a goal; it's a journey, and you're on it.",
    "Your choices for your health are a testament to your commitment.",
    "Together, we're building a future of well-being, one choice at a time.",
    "Your health decisions are a vital link in the journey to wellness.",
    "Your commitment to a healthy life is a lifeline to your well-being.",
    "Keep making choices for well-being and making a positive impact.",
    "The care you provide to yourself extends far beyond the moment.",
    "You trust your instincts for good health, and you never let yourself down.",
    "Every health choice is a step towards a healthier tomorrow.",
    "Your commitment to your health is a beacon of hope for yourself.",
    "In wellness, your choices are a gift of health and vitality.",
    "We're grateful for your commitment to personal well-being.",
    "Your choices are the foundation of better health and happiness.",
    "Living a healthy life is a testament to your dedication to well-being.",
    "Your well-being is better because of the choices you make.",
    "Wellness is better when we work together to prioritize health.",
    "You're making well-being accessible, one choice at a time.",
    "You trust yourself, and you prioritize exceptional self-care.",
    "Your choices are a lifeline to your own better health.",
    "Every choice you make is a step towards a healthier and happier life.",
    "Your choices are a source of strength for your well-being.",
    "Thank you for your dedication to personal well-being.",
    "Your choices are a message of hope and vitality.",
    "You trust your own well-being, and you never disappoint.",
    "Together, we're shaping a future of well-being for all.",
    "Your choices are a vital part of your self-care journey.",
    "Well-being heroes like you make your world a better place."
  ];

  final randomIndex = Random().nextInt(healthPositiveMessages.length);
  return healthPositiveMessages[randomIndex];
}

String dateFormatter(DateTime? value) {
  if (value == null) return '';
  return DateFormat('dd/MM/yyyy').format(value);
}

String slotTimeFormat(DateTime? value) {
  if (value == null) return '';
  return DateFormat('yyyy-MM-dd').format(value);
}

void showDialogFlash(String content, {String title = '', VoidCallback? onTap}) {
  // navigatorKey.currentContext!.showFlash(
  //     constraints: const BoxConstraints(maxWidth: 300),
  //     borderRadius: BorderRadius.circular(25),
  //     title: Text(title, style: const TextStyle(fontSize: 18)),
  //     content: Text(
  //       content,
  //       style: const TextStyle(fontSize: 16),
  //     ),
  //     builder: (context, controller, _) {
  //       return TextButton(
  //           onPressed: onTap ?? () => controller.dismiss(),
  //           child: const Text(
  //             'OK',
  //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
  //           ));
  //     });
}

void showBottomFlash({String? title, String? content}) {
  // showFlash(
  //   context: navigatorKey.currentContext!,
  //   builder: (_, controller) {
  //     return Flash(
  //       controller: controller,
  //       // margin: const EdgeInsets.all(10),
  //       // behavior: FlashBehavior.floating,
  //       position: FlashPosition.bottom,
  //       // borderRadius: BorderRadius.circular(8.0),
  //       forwardAnimationCurve: Curves.easeInCirc,
  //       // backgroundColor: Colors.black,
  //       reverseAnimationCurve: Curves.easeIn,
  //       child: DefaultTextStyle(
  //         style: const TextStyle(color: Colors.white),
  //         child: FlashBar(
  //           title: Text(title ?? ''),
  //           content: Text(
  //             content ?? '',
  //             style: const TextStyle(fontSize: 16),
  //           ),
  //           actions: <Widget>[
  //             TextButton(
  //                 onPressed: () => controller.dismiss(),
  //                 child: const Text('DISMISS')),
  //           ], controller: ,
  //         ),
  //       ),
  //     );
  //   },
  // );
}

BoxDecoration backgroundDecoration(bool shouldCover) => BoxDecoration(
    borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
    image: DecorationImage(
        alignment: Alignment.topCenter,
        fit: shouldCover ? BoxFit.cover : BoxFit.contain,
        image: const AssetImage('images/background.png')));

final dialogBoxDecoration = OutlineInputBorder(
  borderRadius: BorderRadius.circular(15),
  borderSide: BorderSide.none,
);

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

showPopUpDialog(BuildContext context, Widget child,
    {chosenHeight, fullScreen = false}) {
  final height = getScreenHeight(context);

  final width = getScreenWidth(context);

  AlertDialog alert = AlertDialog(
    title: fullScreen
        ? Container(
            width: width,
          )
        : null,
    insetPadding: fullScreen
        ? const EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding * 2,
            vertical: defaultVerticalPadding)
        : EdgeInsets.zero,
    contentPadding: const EdgeInsets.symmetric(
        vertical: defaultVerticalPadding, horizontal: defaultHorizontalPadding),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: chosenHeight ?? height * 0.3),
        child: Center(child: child)),
  );
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return Container(child: alert);
    },
  );
}

Future<void> openLink(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}

bool isImage(File file) {
  // List of common image file extensions
  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic'];

  // Get the file extension
  String extension = file.path.split('.').last.toLowerCase();

  // Check if the file extension is in the list of image extensions
  return imageExtensions.contains(extension);
}

bool isImageUrl(String url) {
  // List of image file extensions
  List<String> imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.svg'
  ];

  // Extract the file extension from the URL path before query parameters
  String urlPath = url.split('?')[0].toLowerCase();
  String extension = urlPath.substring(urlPath.lastIndexOf('.'));

  // Check if the extension is in the list of image extensions
  return imageExtensions.contains(extension);
}

List<Color> showGradient(bool isLoading) => isLoading
    ? [Colors.black87, Colors.black87]
    : const [lightGreen, darkGreen];

Future<T?> push<T>(Widget child) => Navigator.of(navigatorKey.currentContext!)
    .push(MaterialPageRoute(builder: (context) => child));

Future<void> pushReplacement(Widget child) =>
    Navigator.of(navigatorKey.currentContext!)
        .pushReplacement(MaterialPageRoute(builder: (context) => child));

Future<void> pushAndRemoveUntil(Widget child) =>
    Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => child), (c) => false);

extension StringExtention on String {
  String trimText() {
    return length > 30 ? '${substring(0, 30)}...' : this;
  }
}

showAlertDialog(String title, String message, BuildContext context) {
  Alert(
    context: context,
    type: AlertType.info,
    style: alertStyle,
    title: title ?? "",
    desc: message ?? "",
    buttons: [
      DialogButton(
        color: appPrimaryColor,
        onPressed: () => Navigator.pop(context),
        width: 120,
        child: Text(
          "Okay",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ],
  ).show();
}

String formatDistance(int distance) {
  if (distance >= 1000) {
    double distanceKm = distance / 1000;
    return "${distanceKm.toStringAsFixed(1)} km away";
  } else {
    return "$distance m away";
  }
}

String formatCurrency(double amount, String currencyCode) {
  final currencyFormat = NumberFormat.currency(
    locale: 'en', // Change the locale based on your requirement
    symbol: currencyCode,
  );

  return currencyFormat.format(amount);
}

String formatDuration(Duration duration) {
  if (duration.inDays > 0) {
    return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'} left';
  } else if (duration.inHours > 0) {
    return '${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'} left';
  } else if (duration.inMinutes > 0) {
    return '${duration.inMinutes} ${duration.inMinutes == 1 ? 'minute' : 'minutes'} left';
  } else {
    return 'Appointment time';
  }
}

String convertHourToTimeString(int hour) {
  final dateTime =
      DateTime(2023, 1, 1, hour, 0); // Use a fixed date for formatting
  final formattedTime = DateFormat.jm().format(dateTime);
  return formattedTime;
}

//Alerts and Toasts
showCustomToast(String message) {
  Fluttertoast.showToast(
      gravity: ToastGravity.CENTER,
      msg: message,
      webBgColor: appPrimaryColor.value.toString(),
      timeInSecForIosWeb: 5,
      webShowClose: true);
}

showCustomErrorToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      webBgColor: 'red',
      timeInSecForIosWeb: 5,
      gravity: ToastGravity.CENTER,
      webShowClose: true);
}

showSuccessDialog(String title, String message, BuildContext context) {
  Alert(
    context: context,
    type: AlertType.success,
    style: alertStyle,
    title: title,
    desc: message,
    buttons: [
      DialogButton(
        color: Colors.green,
        onPressed: () => Navigator.pop(context),
        width: 120,
        child: Text(
          "Okay",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ],
  ).show();
}

showErrorDialog(String title, String message, BuildContext context) {
  Alert(
    context: context,
    type: AlertType.error,
    style: alertStyle,
    title: title,
    desc: message,
    buttons: [
      DialogButton(
        color: Colors.red,
        onPressed: () => Navigator.of(context).pop(),
        width: 120,
        child: const Text(
          "Okay",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ],
  ).show();
}

showWarningConfirmationAlert(
    String title, String message, BuildContext context) async {
  bool? yes = await Alert(
    context: context,
    type: AlertType.warning,
    style: alertStyle,
    title: title,
    desc: message,
    buttons: [
      DialogButton(
        color: Colors.green,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        width: 120,
        child: const Text(
          "Yes",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      DialogButton(
        color: Colors.red,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
        width: 120,
        child: const Text(
          "No",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    ],
  ).show();

  return yes;
}

Future<bool> showInfoConfirmationAlert(
    String title, String message, BuildContext context) async {
  bool? yes = await Alert(
    context: context,
    type: AlertType.info,
    style: alertStyle,
    title: title,
    desc: message,
    buttons: [
      DialogButton(
        color: Colors.green,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        width: 120,
        child: const Text(
          "Yes",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      DialogButton(
        color: Colors.red,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
        width: 120,
        child: const Text(
          "No",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    ],
  ).show();

  return yes ?? false;
}

//Dimensions

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

String printDuration(Duration duration, {showHours = true}) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${showHours ? "${twoDigits(duration.inHours)}:" : ""}$twoDigitMinutes:$twoDigitSeconds";
}

T randomValue<T>(List<T> list) {
  if (list.isEmpty) {
    throw Exception('Cannot get a random value from an empty list');
  }

  var random = Random();
  int index = random.nextInt(list.length);
  return list[index];
}

/// Wrapper for stateful functionality to provide onInit calls in stateles widget
class StatefulWrapper extends StatefulWidget {
  final Function? onInit;
  final Widget child;
  const StatefulWrapper({super.key, @required this.onInit, required this.child});
  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<StatefulWrapper> {
  @override
  void initState() {
    if (widget.onInit != null) {
      widget.onInit!();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

DateTime adjustServerTime(String dateString) {
  return DateTime.parse(dateString).add(const Duration(hours: 1));
}
