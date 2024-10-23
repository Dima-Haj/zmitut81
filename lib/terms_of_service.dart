import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google fonts package

// Terms of Service page
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
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
                  const Color.fromARGB(255, 57, 51, 42).withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // White frame coming up from the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.87, // Adjust height as needed
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.1),
                  topRight: Radius.circular(screenWidth * 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Center(
                      child: Text(
                        'Terms of Service',
                        style: GoogleFonts.exo2(
                          color: const Color.fromARGB(255, 141, 126, 106),
                          fontSize: screenHeight * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Scrollable content for the Terms
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _termsOfServiceContent(), // Method to generate the terms content
                          style: GoogleFonts.exo2(
                            color: Colors.black.withOpacity(0.8),
                            fontSize:
                                screenHeight * 0.02, // Text size for content
                          ),
                          textAlign: TextAlign.justify, // Justify the text
                        ),
                      ),
                    ),
                    SizedBox(
                        height: screenHeight *
                            0.03), // Space before the "Accept" button

                    // Accept Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 141, 126, 106),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.07),
                        ),
                      ),
                      onPressed: () {
                        // Handle what happens when the user accepts the terms
                        Navigator.pop(context); // Go back to the previous page
                      },
                      child: Text(
                        'Accept',
                        style: GoogleFonts.exo2(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
          // Back arrow button
          Positioned(
            top: screenHeight *
                0.05, // Positioning the arrow in the upper left corner
            left: screenWidth * 0.05,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous page
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method that provides the content of the terms
  String _termsOfServiceContent() {
    return '''
   Welcome to Zmitut 81!

    These terms and conditions outline the rules and regulations for the use of Zmitut 81’s App.

    By accessing this app we assume you accept these terms and conditions. Do not continue to use Zmitut 81 if you do not agree to take all of the terms and conditions stated on this page.

    The following terminology applies to these Terms and Conditions, Privacy Statement and all Agreements: “Client”, “You” and “Your” refers to you, the person logging on this app and compliant to the Company’s terms and conditions. “The Company”, “Ourselves”, “We”, “Our” and “Us”, refers to our Company. “Party”, “Parties”, or “Us”, refers to both the Client and ourselves.

    Cookies:
    We employ the use of cookies. By accessing Zmitut 81, you agreed to use cookies in agreement with the Zmitut 81’s Privacy Policy.

    License:
    Unless otherwise stated, Zmitut 81 and/or its licensors own the intellectual property rights for all material on Zmitut 81. All intellectual property rights are reserved. You may access this from Zmitut 81 for your own personal use subject to restrictions set in these terms and conditions.

    You must not:
    - Republish material from Zmitut 81
    - Sell, rent, or sub-license material from Zmitut 81
    - Reproduce, duplicate, or copy material from Zmitut 81
    - Redistribute content from Zmitut 81

    This Agreement shall begin on the date hereof.
    
    For further details, you can contact us directly at support@zmitut81.com.
    
    Thank you for using Zmitut 81.
    ''';
  }
}
