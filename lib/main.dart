import 'package:flutter/material.dart';
//import 'login_page.dart';
//import 'admin_dashboard_page.dart';
import 'customer_management_page.dart'; // Assuming you have a LoginPage implemented

void main() {
  // Removed Firebase initialization
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZMITUT 81',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CustomerManagementPage(), // Starts with the Login Page
      debugShowCheckedModeBanner: false, // Remove the debug banner
    );
  }
}
