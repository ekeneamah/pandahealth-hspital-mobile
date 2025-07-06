import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

const darkGreen = Color(0xff43ac9a);
const actualDarkGreen = Color(0xff015E36);
const appPrimaryColor = actualDarkGreen;
const lightGreen = Color(0xff6ed895);
const actualLightGreen = Color(0xffE0ECDE);
const primaryColor = Color(0xff56c596);
const darkBlue = Color(0xff205072);
const subheaderColor = Color(0xff707070);
// final cardBackgroundColor = Color(0xffF3F8F3);
final cardBackgroundColor = lightGreen.withOpacity(0.3);

//Alert Styles
const alertStyle = AlertStyle(
    backgroundColor: Colors.white,
    titleStyle: TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
    descStyle: TextStyle(color: Colors.black));

//TextStyles
const headerTextStyle =
    TextStyle(color: darkBlue, fontSize: 16, fontWeight: FontWeight.w800);

const paragraphTextStyle = TextStyle(fontSize: 12);

const subheaderTextStyle =
    TextStyle(color: subheaderColor, fontSize: 14, fontWeight: FontWeight.w800);

const labelHeaderTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: darkBlue);

//Input Decorations

final customBoxDecoration =
    BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.white);

final borderOutlineDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(defaultCardBorderRadius),
    border: Border.all(color: actualDarkGreen, width: 1));

//Dimensions
const double defaultButtonHeight = 50;

const double defaultHorizontalPadding = 15.0;
const double defaultVerticalPadding = 20.0;

//Floating card decoration
const double defaultCardBorderRadius = 15.0;

const noConnection = 'No Internet Connection';
const timeout =
    'Looks like the server is taking to long to respond, You can still try again later.';
const somethingWentWrong = 'Something went wrong';
const unknownError = 'Unknown Error';
const timeLimit = Duration(seconds: 40);

final gender = ['Male', 'Female', 'I rather not say'];

const units = [
  {
    'name': "Metric",
    'values': {'weight': 'kg', 'length': 'cm', 'temperature': 'celcius'}
  },
  {
    'name': "Imperial",
    'values': {'weight': 'lbs', 'length': 'ft', 'temperature': 'fahrenheit'}
  },
];

const iconAssets = {
  'vitals': "images/vitals.png",
  'healthcare': "images/healthcare.png",
  'appointments': "images/appointments.png"
};

const healthStatsTypes = {
  'bp': {
    "name": "Blood Pressure",
    "asset": "images/vitals/blood-pressure.png",
    "suffix": "mm/Hg"
  },
  'temp': {
    "name": "Temperature",
    "asset": "images/vitals/temperature.png",
    "suffix": "Celcius"
  },
  'rr': {
    "name": "Respiratory Rate",
    "asset": "images/vitals/respiratory-rate.png",
    "suffix": "Breaths/min"
  },
};

//Contact Details
String contactPhone = "+234456789234";
String contactEmail = "support@pandahealth.com.ng";
String contactWhatsapp = "https://wa.me/${contactPhone.replaceAll("+", "")}";
String contactTwitter = "https://twitter.com/pandahealth";
String hospitalWebsiteUrl = "https://pandahealthhospital.com";
String clerkingTemplateBaseUrl = "https://pandahealthhospital.com.ng/clerking";

String googleApiKey = "AIzaSyCfNKUY8ljust9sDMjIvdv1cVdati53Qyg";

abstract class Constants {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://staging-health-panda-api.herokuapp.com/api/v1/',
  );
  static const String clerkingTemplateBaseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: "https://pandahealthhospital.com.ng",
  );
}
