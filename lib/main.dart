import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localization
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for locale data initialization
import 'login_page.dart';
import 'signup_step1.dart'; // Import the login_page.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyCQiUTmTw24YY9U93AEHjhWaAPpbgeBTcU",
          authDomain: "zmitut81-1af26.firebaseapp.com",
          projectId: "zmitut81-1af26",
          storageBucket: "zmitut81-1af26.firebasestorage.app",
          messagingSenderId: "986940454516",
          appId: "1:986940454516:web:7d1be798d71fee4f32c321",
          measurementId: "G-424STRBMDR",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    // Initialize locale data for date formatting
    await initializeDateFormatting('he_IL', null);

    runApp(const MyApp());
  } catch (e) {
    debugPrint("Error initializing Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('he', 'IL'), // Set the app locale to Hebrew
      supportedLocales: const [
        Locale('he', 'IL'), // Hebrew locale
        Locale('en', 'US'), // English locale (fallback)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const LoginPage(),
      routes: {
        "SignUp": (context) => const SignupStep1(),
        "login": (context) => const LoginPage(),
      }, // Set LoginPage as the home widget
    );
  }
}
