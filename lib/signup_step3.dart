import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart'; // Import the login page for the cancel button

class SignupStep3 extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String day;
  final String month;
  final String year;
  final String phone;
  final String id;
  final String role;

  SignupStep3({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.day,
    required this.month,
    required this.year,
    required this.phone,
    required this.id,
    required this.role,
  });

  final FirebaseAuthServices _auth = FirebaseAuthServices(); // Initialize here

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    final TextEditingController emailController = TextEditingController();
    final TextEditingController confirmEmailController =
        TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          background(screenHeight),
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: backArrow(context),
          ),
          Positioned(
            top: screenHeight * 0.03,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo_zmitut.png',
                height: screenHeight * 0.06,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.65,
              decoration: whiteFrame(screenWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Center(
                      child: Text(
                        'Create Account',
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
                    buildTextField(
                        'Email', Icons.email, emailController, screenWidth),
                    SizedBox(height: screenHeight * 0.02),
                    buildTextField('Confirm Email', Icons.email_outlined,
                        confirmEmailController, screenWidth),
                    SizedBox(height: screenHeight * 0.02),
                    buildTextFieldWithPasswordInfo(context, 'Password',
                        Icons.lock, passwordController, screenWidth, true),
                    SizedBox(height: screenHeight * 0.02),
                    buildTextField('Confirm Password', Icons.lock_outline,
                        confirmPasswordController, screenWidth,
                        obscureText: true),
                    SizedBox(height: screenHeight * 0.03),
                    signUpButton(
                        context,
                        screenHeight,
                        screenWidth,
                        emailController,
                        confirmEmailController,
                        passwordController,
                        confirmPasswordController),
                    SizedBox(height: screenHeight * 0.02),
                    cancelButton(context, screenHeight, screenWidth),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration whiteFrame(double screenWidth) => BoxDecoration(
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
      );

  Widget background(double screenHeight) => Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/image1.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color(0x9939332A),
              BlendMode.darken,
            ),
          ),
        ),
      );

  Widget buildTextField(
    String hintText,
    IconData icon,
    TextEditingController controller,
    double screenWidth, {
    bool obscureText = false,
  }) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: Border.all(
            color: const Color.fromARGB(255, 141, 126, 106),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 141, 126, 106)),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                style: GoogleFonts.exo2(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildTextFieldWithPasswordInfo(
    BuildContext context,
    String hintText,
    IconData icon,
    TextEditingController controller,
    double screenWidth, [
    bool obscureText = false,
  ]) =>
      Stack(
        children: [
          buildTextField(hintText, icon, controller, screenWidth,
              obscureText: obscureText),
          Positioned(
            right: 10,
            top: 5,
            child: IconButton(
              icon: Icon(Icons.info_outline, size: 20, color: Colors.red),
              onPressed: () => showPasswordInfo(context),
            ),
          ),
        ],
      );

  Widget signUpButton(
    BuildContext context,
    double screenHeight,
    double screenWidth,
    TextEditingController emailController,
    TextEditingController confirmEmailController,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController,
  ) =>
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 141, 126, 106),
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          if (emailController.text.isEmpty ||
              confirmEmailController.text.isEmpty ||
              passwordController.text.isEmpty ||
              confirmPasswordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All fields must be filled')));
            return;
          }

          if (emailController.text != confirmEmailController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emails do not match')));
            return;
          }

          if (passwordController.text != confirmPasswordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Passwords do not match')));
            return;
          }

          User? user = await _auth.signUpWithEmailAndPassword(
              emailController.text, passwordController.text);

          if (user != null) {
            if (role == "Manager") {
              print("role");
              FirebaseFirestore.instance
                  .collection('Managers')
                  .doc(user.uid)
                  .set({
                'firstName': firstName,
                'lastName': lastName,
                'birthDay': day,
                'birthMonth': month,
                'birthYear': year,
                'phone': phone,
                'id': id,
                'email': emailController.text,
              });
            } else {
              FirebaseFirestore.instance
                  .collection('Employees')
                  .doc(user.uid)
                  .set({
                'firstName': firstName,
                'lastName': lastName,
                'birthDay': day,
                'birthMonth': month,
                'birthYear': year,
                'phone': phone,
                'id': id,
                'email': emailController.text,
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User added successfully')));
            Navigator.popUntil(context, (route) => route.isFirst);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to sign up')));
          }
        },
        child: Text(
          'SIGN UP',
          style: GoogleFonts.exo2(
            color: Colors.white,
            fontSize: screenHeight * 0.023,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.3,
          ),
        ),
      );

  Widget cancelButton(
          BuildContext context, double screenHeight, double screenWidth) =>
      Column(
        children: [
          Divider(color: Colors.grey, thickness: 1),
          TextButton(
            child: Text(
              'Cancel',
              style: GoogleFonts.exo2(
                  color: Colors.red, fontSize: screenHeight * 0.02),
            ),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            ),
          ),
        ],
      );

  void showPasswordInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Strength'),
        content: const Text(
            'Passwords should be at least 8 characters long and include numbers, symbols, and upper/lower case letters.'),
        actions: [
          TextButton(
            child: const Text('Got it'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Widget backArrow(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        onPressed: () => Navigator.pop(context),
      );
}
