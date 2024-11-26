// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_step1.dart'; // Import the login_page.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCQiUTmTw24YY9U93AEHjhWaAPpbgeBTcU",
            authDomain: "zmitut81-1af26.firebaseapp.com",
            projectId: "zmitut81-1af26",
            storageBucket: "zmitut81-1af26.firebasestorage.app",
            messagingSenderId: "986940454516",
            appId: "1:986940454516:web:7d1be798d71fee4f32c321",
            measurementId: "G-424STRBMDR"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
        routes: {
          "SignUp": (context) => SignupStep1(),
          "login": (context) => LoginPage()
        } // Set LoginPage as the home widget
        );
  }
}
