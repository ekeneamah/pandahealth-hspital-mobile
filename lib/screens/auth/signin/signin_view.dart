import 'package:flutter/material.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/button_loader.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:pandahealthhospital/custom_widgets/login_textfield.dart';
import 'package:pandahealthhospital/screens/auth/forgot_password/forgot_password_view.dart';
import 'package:pandahealthhospital/screens/auth/form_validation.dart';
import 'package:pandahealthhospital/screens/auth/signup/signup_view.dart';
import 'package:pandahealthhospital/screens/tabs_screen.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/utils/app_functions.dart';
import 'package:pandahealthhospital/utils/utils.dart';

// import 'package:healthpanda_patient/views/authentication/set_passcode/set_passcode_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final formkey = GlobalKey<FormState>();
  final userCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool obscureText = true;
  void get onIconToggle => setState(() => obscureText = !obscureText);
  IconData get icon => !obscureText ? Icons.visibility : Icons.visibility_off;

  bool isLoading = false;
  final FirebaseServices _firebaseServices = FirebaseServices();

  void login() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      var res = await _firebaseServices.signInWithEmailAndPasswordAsHospital(
          context, userCtrl.text.trim(), passwordCtrl.text.trim());
      setState(() {
        isLoading = false;
      });
      if (res) {
        push(const BottomNavigationScreen());
      } else {
        showCustomErrorToast("Error Signing In");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = getWidth(context);
    final height = getHeight(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
                width: width,
                height: height,
                child: Image.asset("images/login_background.png")),
            SizedBox(
              width: width,
              height: height,
              child: SafeArea(
                  minimum: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formkey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const CustomTitleBar(image: 'images/app-icon.png'),
                          const Text('Healthcare Centre Login',
                              style: headerTextStyle),
                          const SizedBox(height: 20),
                          const Text(
                              'Enter your login details to\naccess your account',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: lightGreen, fontSize: 16)),
                          const SizedBox(height: 30),
                          LoginTextField(
                              controller: userCtrl,
                              hint: 'Email',
                              checkboxCtrl: userCtrl,
                              autofillHints: const [AutofillHints.email],
                              textCapitalization: TextCapitalization.none,
                              isValidated: emailRegExp.hasMatch(userCtrl.text),
                              validator: (val) => validateEmail(val!),
                              onChanged: (val) => setState(() {})),
                          const SizedBox(height: 10),
                          LoginTextField(
                              controller: passwordCtrl,
                              checkboxCtrl: passwordCtrl,
                              hint: 'Password',
                              isValidated: true,
                              validator: (val) =>
                                  val!.isEmpty ? 'Field is required' : null,
                              obscureText: obscureText,
                              suffixIcon: IconButton(
                                onPressed: () => onIconToggle,
                                icon: Icon(icon, color: lightGreen),
                              )),
                          const SizedBox(height: 30),
                          TextButton(
                            onPressed: () =>
                                navigateToScreen(context, const ForgotPasswordView()),
                            child: const Text('Forgot Password?',
                                style: TextStyle(
                                    color: lightGreen,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            isLoading: isLoading,
                            radius: 22,
                            onPressed: login,
                            gradient: showGradient(isLoading),
                            child: ButtonLoader(
                                isLoading: isLoading, text: 'LOG IN'),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: CustomButton(
                              height: 40,
                              onPressed: () =>
                                  navigateToScreen(context, const SignUpView()),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Not a member?',
                                      style: TextStyle(color: lightGreen)),
                                  SizedBox(width: 4),
                                  Text('Sign Up',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: darkBlue))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
