import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/firebase_options.dart';
import 'package:pandahealthhospital/screens/auth/loading.dart';
import 'package:pandahealthhospital/screens/welcome_screen/welcome_screen.dart';
import 'package:pandahealthhospital/screens/widgets/idle_detector.dart';
import 'package:pandahealthhospital/services/firebase_services.dart';
import 'package:pandahealthhospital/stores/user_store.dart';
import 'package:pandahealthhospital/utils/utils.dart';

import 'package:provider/provider.dart';

// Create a global instance of FirebaseServices
final FirebaseServices firebaseServices = FirebaseServices();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the Firebase auth state listener
  firebaseServices.initAuthStateListener();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserStore()),
    Provider<FirebaseServices>.value(value: firebaseServices),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return IdleDetector(
    //   idleTime: const Duration(minutes: 30),
    //   onIdle: () async {
    //     if (kDebugMode) {
    //       return;
    //     }

    //     try {
    //       final firebaseService = FirebaseServices();
    //       if (firebaseService.firebaseAuth.currentUser != null) {
    //         print("User is logged in. Performing logout");
    //         await firebaseService.logout();

    //         navigatorKey.currentState?.pushAndRemoveUntil(
    //           MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    //           (route) => false,
    //         );
    //       } else {
    //         print("No user logged in - skipping logout");
    //       }
    //     } catch (e) {
    //       print("Error performing logout: $e");
    //     }
    //   },
    //   child:
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Panda Health Hospital',
      theme: ThemeData(
        fontFamily: "Product_Sans_Font",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green,
          secondary: Colors.greenAccent,
          tertiary: Colors.lightGreen,
          surface: Colors.white,
          background: Colors.grey[100]!,
          error: Colors.redAccent,
          onPrimary: Colors.white,
          onSecondary: Colors.black87,
          onTertiary: Colors.black87,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
        ),
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      navigatorKey: navigatorKey,
      home: const LoadingScreen(),
    );

    // );
  }
}
