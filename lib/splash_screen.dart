import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart'; // Import the LoginPage

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to login page after 3 seconds
    Timer(const Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    // ignore: unused_local_variable
    final double screenWidth = screenSize.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            height: screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/image1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color.fromARGB(255, 57, 51, 42).withOpacity(0.8),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Company Name in the center with "UT 81" styled differently
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'ZMIT', // First part with the regular theme color
                    style: GoogleFonts.exo2(
                      textStyle: TextStyle(
                        color: const Color.fromARGB(
                            255, 255, 255, 255), // Same color as other elements
                        fontSize: screenHeight * 0.07, // Adjust size as needed
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,

                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 8.0,
                            color: const Color.fromARGB(255, 141, 126, 106)
                                .withOpacity(0.9), // White shadow
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextSpan(
                    text: 'UT 81', // Second part ("UT 81") in white
                    style: GoogleFonts.exo2(
                      textStyle: TextStyle(
                        color:
                            const Color(0xFFFFFFFF), // White color for "UT 81"
                        fontSize: screenHeight *
                            0.07, // Adjust size to match the first part
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,

                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 8.0,
                            color: const Color.fromARGB(255, 141, 126, 106)
                                .withOpacity(0.9), // White shadow
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
