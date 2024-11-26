import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin_dashboard_page.dart';
import 'package:flutter_application_1/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart'; // Google fonts package
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Font Awesome package for icons
import 'signup_step1.dart'; // Make sure this path is correct
import 'terms_of_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'employee_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  List<Map<String, dynamic>> employeeData = [];
  bool isHoveredEmail = false;
  bool isEmailFocused = false;
  bool isHoveredPassword = false;
  bool isPasswordFocused = false;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final TextEditingController emailController =
      TextEditingController(); // Controller to access email text
  final TextEditingController passwordController =
      TextEditingController(); // Added password controller

@override
void initState() {
  super.initState();

  // Add listeners for email and password focus nodes
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
}

@override
void dispose() {
  // Dispose the focus nodes properly
  emailFocusNode.dispose();
  passwordFocusNode.dispose();

  // Dispose the controllers
  emailController.dispose();
  passwordController.dispose();

  super.dispose();
}

  final FirebaseAuthServices _auth = FirebaseAuthServices();
  // Method to handle login logic
 void handleLogin() async {
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
    }
    return;
  }

  try {
    // Authenticate user
    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user == null) {
      // Authentication failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect email or password.')),
        );
      }
      return;
    }

    // Check if the user exists in the 'Managers' collection
    DocumentSnapshot<Map<String, dynamic>> managerDoc =
        await FirebaseFirestore.instance.collection('Managers').doc(user.uid).get();

    if (managerDoc.exists) {
      // Navigate to Admin Dashboard if user is a manager
      final managerDetails = {
        'id': user.uid,
        'email': user.email ?? '',
        ...managerDoc.data()!,
      };

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminDashboard(managerDetails: managerDetails),
          ),
        );
      }
      return;
    }

    // Check if the user exists in the 'Employees' collection
    DocumentSnapshot<Map<String, dynamic>> employeeDoc =
        await FirebaseFirestore.instance.collection('Employees').doc(user.uid).get();

    if (employeeDoc.exists) {
      // Navigate to Employee Home Page if user is an employee
      final employeeDetails = {
        'id': user.uid,
        'email': user.email ?? '',
        ...employeeDoc.data()!,
      };

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EmployeeHomePage(employeeDetails: employeeDetails),
          ),
        );
      }
    } else {
      // User is not found in either collection
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User record not found.')),
        );
      }
    }
  } catch (e) {
    // Handle errors
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }
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
          Positioned(
            top: screenHeight * 0.03,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo_zmitut.png',
                height: screenHeight * 0.06, // Adjust the height as needed
              ),
            ),
          ),

          // White frame coming up from the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.65, // Adjust height as needed
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
                    SizedBox(height: screenHeight * 0.03),

                    // "Sign in to continue" Text
                    Center(
                      child: Text(
                        'Sign in to continue',
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
                    MouseRegion(
                      onEnter: (_) => setState(() => isHoveredEmail = true),
                      onExit: (_) => setState(() => isHoveredEmail = false),
                      child: buildTextField(
                        'Email',
                        Icons.email,
                        screenWidth,
                        focusNode: emailFocusNode,
                        isFocused: isEmailFocused,
                        isHovered: isHoveredEmail,
                        controller:
                            emailController, // Use controller to access text
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Password Field
                    MouseRegion(
                      onEnter: (_) => setState(() => isHoveredPassword = true),
                      onExit: (_) => setState(() => isHoveredPassword = false),
                      child: buildTextField(
                        'Password',
                        Icons.lock,
                        screenWidth,
                        focusNode: passwordFocusNode,
                        isFocused: isPasswordFocused,
                        isHovered: isHoveredPassword,
                        obscureText: true,
                        controller: passwordController,
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.exo2(
                            color: const Color.fromARGB(255, 141, 126, 106),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Login Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 141, 126, 106),
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                        ),
                      ),
                      onPressed: handleLogin, // Call handleLogin on press
                      child: Text(
                        'SIGN IN',
                        style: GoogleFonts.exo2(
                          color: Colors.white,
                          fontSize: screenHeight * 0.023,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.3,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.exo2(color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupStep1()),
                            );
                          },
                          child: Text(
                            'Sign Up'.toUpperCase(),
                            style: GoogleFonts.exo2(
                              color: const Color.fromARGB(255, 141, 126, 106),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Social Media Buttons
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
                  ],
                ),
              ),
            ),
          ),

          // Bottom Section (Terms of Service)
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

  Widget buildTextField(String hintText, IconData icon, double screenWidth,
      {bool obscureText = false,
      required FocusNode focusNode,
      required bool isHovered,
      required bool isFocused,
      TextEditingController? controller}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(
          color: const Color.fromARGB(255, 141, 126, 106), // Border color
          width: 1.0, // Border width
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
              controller: controller, // Connect the controller here
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
                    color:
                        Color.fromARGB(255, 141, 126, 106), // Hint text color
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
        color: Colors.white, // White background for the button
        borderRadius:
            BorderRadius.circular(screenWidth * 0.07), // Rounded corners
        border: Border.all(
          color: borderColor, // Border color passed in the parameter
          width: 1.5, // Border width
        ),
      ),
      child: IconButton(
        icon: FaIcon(icon), // Icon data (e.g., Facebook, Google, Phone)
        color: borderColor, // Icon color matches the border
        onPressed: () {
          // Handle social button press here
        },
      ),
    );
  }
}
