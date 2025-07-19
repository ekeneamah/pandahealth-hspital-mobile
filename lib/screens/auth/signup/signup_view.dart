// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/constants/data.dart';
import 'package:pandahealthhospital/custom_widgets/button_loader.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/custom_widgets/file_upload_field.dart';
import 'package:pandahealthhospital/custom_widgets/file_upload_preview.dart';
import 'package:pandahealthhospital/custom_widgets/image_upload_preview.dart';
import 'package:pandahealthhospital/custom_widgets/login_textfield.dart';
import 'package:pandahealthhospital/screens/auth/email_validation/awaiting_email_validation.dart';
import 'package:pandahealthhospital/screens/hospital/pick_location.dart';
import 'package:pandahealthhospital/screens/tabs_screen.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/utils/utils.dart';
import 'package:phone_form_field/phone_form_field.dart';
import '../form_validation.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final formkey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
   // final accessCodeCtrl = TextEditingController();
  final phoneController = PhoneController(
    initialValue: const PhoneNumber(
      isoCode: IsoCode.NG,
      nsn: '',
    ),
  );

  bool obscureText = true;
  String? selectedGender;
  String? selectedState;
  String? selectedCity;
  DateTime? selectedDateOfBirth;
  String? nsn;
  Color borderColor = lightGreen;
  final FirebaseServices _firebaseServices = FirebaseServices();
  bool isLoading = false;

  // Add file variables
  File? proofOfOwnership;
  File? profileImage;

  // Add location coordinates
  double? latitude;
  double? longitude;

  int currentStep = 0;
  final totalSteps = 3;

  List<Widget> buildSteps() {
    return [
      // Step 1: Basic Info
      Column(
        children: [
          /* LoginTextField(
              controller: accessCodeCtrl,
              hint: 'Healthcare Access Code',
              autofillHints: const [AutofillHints.organizationName],
              isValidated: accessCodeCtrl.text.isNotEmpty,
              validator: (val) =>
                  val!.isEmpty ? 'Healthcare Centre access code is required' : null,
              onChanged: (val) => setState(() {})), */
          const SizedBox(height: 10),
          LoginTextField(
              controller: nameCtrl,
              hint: 'Healthcare Centre Name',
              autofillHints: const [AutofillHints.organizationName],
              isValidated: nameCtrl.text.isNotEmpty,
              validator: (val) =>
                  val!.isEmpty ? 'Healthcare Centre name is required' : null,
              onChanged: (val) => setState(() {})),
          const SizedBox(height: 10),
          LoginTextField(
              controller: emailCtrl,
              hint: 'Business Email',
              autofillHints: const [AutofillHints.email],
              textCapitalization: TextCapitalization.none,
              isValidated: emailRegExp.hasMatch(emailCtrl.text),
              validator: (val) => validateEmail(val!),
              onChanged: (val) => setState(() {})),
          const SizedBox(height: 10),
          LoginTextField(
              controller: passwordCtrl,
              hint: 'Password',
              obscureText: obscureText,
              suffixIcon: IconButton(
                  onPressed: onIconToggle, icon: Icon(icon, color: lightGreen)),
              isValidated: true,
              validator: (val) => validatePassword(val!),
              onChanged: (val) => setState(() {})),
          const SizedBox(height: 10),
          LoginTextField(
              controller: confirmPassCtrl,
              hint: 'Confirm Password',
              obscureText: obscureText,
              suffixIcon: IconButton(
                  onPressed: onIconToggle, icon: Icon(icon, color: lightGreen)),
              isValidated: confirmPassCtrl.text == passwordCtrl.text,
              validator: (val) =>
                  val != passwordCtrl.text ? 'Passwords do not match' : null,
              onChanged: (val) => setState(() {})),
        ],
      ),

      // Step 2: Location Info
      Column(
        children: [
          PhoneFormField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
            ),
            validator: (phoneNumber) {
              if (phoneNumber == null || phoneNumber.nsn.isEmpty) {
                return 'Phone number is required';
              }
              if (!phoneNumber.isValid()) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedState,
            decoration: const InputDecoration(
              labelText: 'State',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
            ),
            items: statesAndCities
                .map((state) => DropdownMenuItem(
                      value: state['name'] as String,
                      child: Text(state['name'] as String),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedState = value;
                selectedCity = null;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a state' : null,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedCity,
            decoration: const InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
            ),
            items: selectedState != null
                ? citiesForState(selectedState!)
                    .map((city) =>
                        DropdownMenuItem(value: city, child: Text(city)))
                    .toList()
                : [],
            onChanged: (value) => setState(() => selectedCity = value),
            validator: (value) => value == null ? 'Please select a city' : null,
          ),
          const SizedBox(height: 10),
          _buildLocationInfo(),
        ],
      ),
      // Step 3: Documents
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documents(Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ImageUploadPreview(
            imageFile: profileImage,
            label: 'Hospital Logo',
            onPickImage: () async {
              final file =
                  await pickFile(allowedExtensions: ['jpg', 'jpeg', 'png']);
              if (file != null) {
                setState(() => profileImage = file);
              }
            },
          ),
          const SizedBox(height: 16),
          FileUploadPreview(
            file: proofOfOwnership,
            label: 'Proof of Ownership',
            onPickFile: () async {
              final file = await pickFile(
                  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
              if (file != null) {
                setState(() => proofOfOwnership = file);
              }
            },
          ),
        ],
      ),
    ];
  }

  void onIconToggle() => setState(() => obscureText = !obscureText);
  IconData get icon => !obscureText ? Icons.visibility : Icons.visibility_off;

  Future<void> pickDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDateOfBirth) {
      setState(() {
        selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> register() async {
    if (formkey.currentState!.validate()) {
      setState(() => isLoading = true);

      // Upload files if they exist (now optional)
      List<String> proofUrls = [];
      String? profileImageUrl;

      if (proofOfOwnership != null) {
        proofUrls = await _firebaseServices.uploadFiles([proofOfOwnership!]);
      }

      if (profileImage != null) {
        var profileUrls = await _firebaseServices.uploadFiles([profileImage!]);
        if (profileUrls.isNotEmpty) {
          profileImageUrl = profileUrls[0];
        }
      }

      final hospitalData = {
       //  'accessCode': accessCodeCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phoneNumber': phoneController.value.international,
        'address': addressCtrl.text.trim(),
        'state': selectedState,
        'city': selectedCity,
        'lat': latitude,
        'lng': longitude,
        'centerLogo': profileImageUrl, // Optional
        'documents': proofUrls.isNotEmpty
            ? [
                {'url': proofUrls[0], 'name': 'Proof of Ownership'}
              ]
            : [] // Empty array if no documents
      };

      var res = await _firebaseServices.signUpHospital(
          passwordCtrl.text.trim(), hospitalData);

      if (res == true) {
        // Sign in the user after successful registration
        final signInResult =
            await _firebaseServices.signInWithEmailAndPasswordAsHospital(
          context,
          emailCtrl.text.trim(),
          passwordCtrl.text.trim(),
        );

        setState(() => isLoading = false);

        if (signInResult) {
          // Send verification email
          await _firebaseServices.sendEmailVerification();
          push(const AwaitingEmailValidationScreen());
        } else {
          showCustomErrorToast(
              "Registration successful but error signing in. Please sign in manually.");
        }
      } else {
        setState(() => isLoading = false);
        showCustomErrorToast(res as String);
      }
    }
  }

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: darkBlue),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  List<String> citiesForState(String state) {
    final stateData = statesAndCities.firstWhere(
      (s) => s['name'] == state,
      orElse: () => {'name': '', 'cities': <String>[]},
    );
    return (stateData['cities'] as List<dynamic>).cast<String>();
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoginTextField(
          controller: addressCtrl,
          hint: 'Address',
          validator: (val) => val!.isEmpty ? 'Address is required' : null,
          onChanged: (val) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on, color: lightGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Location Coordinates',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (latitude != null && longitude != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Latitude: ${latitude!.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Longitude: ${longitude!.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PickLocation(
                          onLocationPicked: (lat, lng) {
                            setState(() {
                              latitude = lat;
                              longitude = lng;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    latitude != null
                        ? 'Change Location'
                        : 'Pick Location on Map',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool isStepValid() {
    switch (currentStep) {
      case 0:
        return nameCtrl.text.isNotEmpty /* && accessCodeCtrl.text.isNotEmpty &&
            accessCodeCtrl.text.length == 6 */ &&
            emailCtrl.text.isNotEmpty &&
            emailRegExp.hasMatch(emailCtrl.text) &&
            passwordCtrl.text.isNotEmpty &&
            confirmPassCtrl.text == passwordCtrl.text;
      case 1:
        return phoneController.value.isValid() &&
            selectedState != null &&
            selectedCity != null &&
            addressCtrl.text.isNotEmpty &&
            latitude != null &&
            longitude != null;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _handleContinue() {
    if (!formkey.currentState!.validate()) {
      return;
    }

    if (currentStep < totalSteps - 1) {
      setState(() => currentStep++);
    } else {
      register();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: formkey,
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      buildSteps()[currentStep],
                      const SizedBox(height: 35),
                      CustomButton(
                          isLoading: isLoading,
                          radius: 22,
                          onPressed: _handleContinue,
                          gradient: showGradient(isLoading),
                          child: ButtonLoader(
                              isLoading: isLoading,
                              text: currentStep < totalSteps - 1
                                  ? 'CONTINUE'
                                  : 'JOIN')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
