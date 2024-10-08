// main.dart
import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login_page.dart file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // You can define a global theme here if needed
          ),
      home: const LoginPage(), // Set LoginPage as the home widget
    );
  }
}
