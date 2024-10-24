import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart'; // Google fonts package
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Font Awesome for icons
import 'terms_of_service.dart'; // Import the Terms of Service page

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  bool isHoveredEmail = false;
  bool isEmailFocused = false;
  bool isHoveredPassword = false;
  bool isPasswordFocused = false;
  bool isHoveredConfirmPassword = false;
  bool isConfirmPasswordFocused = false;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    emailFocusNode.addListener(() {
      setState(() {
        isEmailFocused = emailFocusNode.hasFocus;
      });
    });
    passwordFocusNode.addListener(() {
      setState(() {
        isPasswordFocused = passwordFocusNode.hasFocus;
      });
    });
    confirmPasswordFocusNode.addListener(() {
      setState(() {
        isConfirmPasswordFocused = confirmPasswordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Back arrow button
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: screenHeight * 0.04,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo_zmitut.png',
                height: screenHeight * 0.08, // Adjust the height as needed
              ),
            ),
          ),

          // White frame coming up from the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.8,
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
                        'Create your account',
                        style: GoogleFonts.exo2(
                          textStyle: TextStyle(
                            color: const Color.fromARGB(255, 141, 126, 106),
                            fontSize: screenHeight * 0.027,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Email Field
                    buildTextField(
                      'Email',
                      Icons.email,
                      screenWidth,
                      _emailController,
                      focusNode: emailFocusNode,
                      isFocused: isEmailFocused,
                      isHovered: isHoveredEmail,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Password Field
                    buildTextField(
                      'Password',
                      Icons.lock,
                      screenWidth,
                      _passwordController,
                      focusNode: passwordFocusNode,
                      isFocused: isPasswordFocused,
                      isHovered: isHoveredPassword,
                      obscureText: true,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Confirm Password Field
                    buildTextField(
                      'Confirm Password',
                      Icons.lock,
                      screenWidth,
                      _confirmPasswordController,
                      focusNode: confirmPasswordFocusNode,
                      isFocused: isConfirmPasswordFocused,
                      isHovered: isHoveredConfirmPassword,
                      obscureText: true,
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Create Account Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 141, 126, 106),
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                        ),
                      ),
                      onPressed: _signUp,
                      child: Text(
                        'SIGN UP',
                        style: GoogleFonts.exo2(
                          color: Colors.white,
                          fontSize: screenHeight * 0.023,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.3,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Social Media Sign-up Buttons
                    Center(
                      child: Text(
                        'Or sign up with',
                        style: GoogleFonts.exo2(
                          textStyle: TextStyle(
                            color: const Color.fromARGB(255, 141, 126, 106),
                            fontSize: screenHeight * 0.02,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Social Media Buttons Row (like login page)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: buildSocialButton(
                            FontAwesomeIcons.facebookF,
                            screenWidth,
                            screenHeight,
                            const Color.fromARGB(255, 141, 126, 106),
                          ),
                        ),
                        Expanded(
                          child: buildSocialButton(
                            FontAwesomeIcons.google,
                            screenWidth,
                            screenHeight,
                            const Color.fromARGB(255, 141, 126, 106),
                          ),
                        ),
                        Expanded(
                          child: buildSocialButton(
                            Icons.phone,
                            screenWidth,
                            screenHeight,
                            const Color.fromARGB(255, 141, 126, 106),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Section (Terms of Service) - Fixed at the bottom
          Positioned(
            bottom: 0,
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
              width: screenWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'By using Zmitut 81 App, you are agreeing to our',
                    style: GoogleFonts.exo2(
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TermsOfServicePage()),
                      );
                    },
                    child: Text(
                      'Terms of Service',
                      style: GoogleFonts.exo2(
                        color: const Color.fromARGB(255, 141, 126, 106),
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

  Widget buildTextField(
    String hintText,
    IconData icon,
    double screenWidth,
    TextEditingController controller, {
    bool obscureText = false,
    required FocusNode focusNode,
    required bool isHovered,
    required bool isFocused,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(
          color: const Color.fromARGB(255, 141, 126, 106),
          width: 1.0,
        ),
        boxShadow: isHovered || isFocused
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 141, 126, 106)),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              style: GoogleFonts.exo2(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.exo2(
                  textStyle: const TextStyle(
                    color: Color.fromARGB(255, 141, 126, 106),
                  ),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSocialButton(IconData icon, double screenWidth,
      double screenHeight, Color borderColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      height: screenHeight * 0.07, // Dynamically set height for buttons
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(screenWidth * 0.07), // Rounded corners
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: IconButton(
        icon: FaIcon(icon),
        color: borderColor,
        onPressed: () {
          // Handle social button press here
        },
      ),
    );
  }
}
