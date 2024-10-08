// login_page.dart
import 'package:flutter/material.dart'; // Import for Flutter widgets
import 'package:google_fonts/google_fonts.dart'; // Google fonts package
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Font Awesome package for icons
import 'create_account_page.dart'; // Import the CreateAccountPage for navigation

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents resizing when the keyboard appears
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Container(
              height: screenHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(
                      'assets/images/wallpaper.webp'), // Your image path
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7), // Dim the image
                    BlendMode.darken,
                  ),
                ),
              ),
            ),

            // Foreground Content
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth *
                            0.06, // Dynamically set padding based on screen width
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                              height: screenHeight *
                                  0.05), // Dynamically set top space based on screen height

                          // Title
                          Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Zmit',
                                    style: GoogleFonts.exo2(
                                      textStyle: TextStyle(
                                        color: const Color(0xFFD6985D),
                                        fontSize: screenHeight *
                                            0.07, // Scale font size with screen height
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 1.5,
                                            color: Colors.black,
                                            offset: Offset(
                                                screenWidth * 0.02,
                                                screenWidth *
                                                    0.02), // Shadow offset
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'ut 81',
                                    style: GoogleFonts.exo2(
                                      color: Colors.white,
                                      fontSize: screenHeight *
                                          0.07, // Scale font size with screen height
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 1.5,
                                          color: Colors.black,
                                          offset: Offset(
                                              screenWidth * 0.02,
                                              screenWidth *
                                                  0.02), // Shadow offset
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                              height: screenHeight *
                                  0.2), // Dynamic space between title and form

                          // Email Field
                          Container(
                            padding: EdgeInsets.all(screenWidth *
                                0.02), // Adjust padding dynamically
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(screenWidth *
                                    0.07), // Scale radius with screen width
                                topRight: Radius.circular(screenWidth * 0.07),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.email, color: Colors.white),
                                SizedBox(
                                    width: screenWidth *
                                        0.03), // Space between icon and text field
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(color: Colors.white),
                                      border: InputBorder.none,
                                    ),
                                    style:
                                        GoogleFonts.exo2(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Password Field
                          Container(
                            padding: EdgeInsets.all(screenWidth *
                                0.02), // Adjust padding dynamically
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(screenWidth *
                                    0.07), // Scale radius with screen width
                                bottomRight:
                                    Radius.circular(screenWidth * 0.07),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock, color: Colors.white),
                                SizedBox(
                                    width: screenWidth *
                                        0.03), // Space between icon and text field
                                Expanded(
                                  child: TextField(
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: TextStyle(color: Colors.white),
                                      border: InputBorder.none,
                                    ),
                                    style:
                                        GoogleFonts.exo2(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                              height: screenHeight *
                                  0.01), // Dynamic space between form and other elements

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.exo2(color: Colors.white),
                              ),
                            ),
                          ),

                          SizedBox(
                              height: screenHeight *
                                  0.02), // Dynamic space before Login button

                          // Login Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.6),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight *
                                    0.02, // Adjust vertical padding based on screen height
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.07),
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: const Color(0xFFD6985D),
                                fontSize:
                                    screenHeight * 0.025, // Scale text size
                              ),
                            ),
                          ),

                          SizedBox(
                              height: screenHeight *
                                  0.02), // Dynamic space between buttons

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.exo2(color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to the CreateAccountPage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CreateAccountPage()),
                                  );
                                },
                                child: const Text(
                                  'Sign up now',
                                  style: TextStyle(
                                    color: Color(0xFFD6985D),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                              height: screenHeight *
                                  0.03), // Space before social media buttons

                          // Social Media Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02),
                                  height: screenHeight *
                                      0.07, // Dynamically set height for buttons
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD6985D)
                                        .withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.07),
                                  ),
                                  child: IconButton(
                                    icon: const FaIcon(
                                        FontAwesomeIcons.facebookF),
                                    color: Colors.white,
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02),
                                  height: screenHeight *
                                      0.07, // Dynamically set height for buttons
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD6985D)
                                        .withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.07),
                                  ),
                                  child: IconButton(
                                    icon: const FaIcon(FontAwesomeIcons.google),
                                    color: Colors.white,
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02),
                                  height: screenHeight *
                                      0.07, // Dynamically set height for buttons
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD6985D)
                                        .withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.07),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.phone),
                                    color: Colors.white,
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Section (Terms of Service)
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'By using Mintly, you are agreeing to our',
                        style: GoogleFonts.exo2(color: Colors.white),
                      ),
                      const Text(
                        'Terms of Service',
                        style: TextStyle(
                          color: Color(0xFFD6985D),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
