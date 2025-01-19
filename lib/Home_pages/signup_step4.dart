import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Designed_helper_fields/firebase_auth_services.dart';
import 'login_page.dart';

class SignupStep4 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String day;
  final String month;
  final String year;
  final String phone;
  final String id;
  final String role;
  final String truckType;
  final String truckSize;
  final String email;

  SignupStep4({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.day,
    required this.month,
    required this.year,
    required this.phone,
    required this.id,
    required this.role,
    required this.truckType,
    required this.truckSize,
    required this.email,
  });
  @override
  _SignupStep4State createState() => _SignupStep4State();
}

class _SignupStep4State extends State<SignupStep4> {
  final FirebaseAuthServices _auth = FirebaseAuthServices(); // Initialize here
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Unfocus the current focus node to dismiss the keyboard
          FocusScope.of(context).unfocus();
        },
        child: Stack(
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
                height: screenHeight * 0.55,
                decoration: whiteFrame(screenWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      Center(
                        child: Text(
                          'צור חשבון',
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
                      Directionality(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
                        child: buildTextFieldWithPasswordInfo(
                          context,
                          'סיסמה', // Hebrew for "Password"
                          Icons.lock,
                          passwordController,
                          screenWidth,
                          true,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Directionality(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
                        child: buildTextField(
                          'אישור סיסמה', // Hebrew for "Confirm Password"
                          Icons.lock_outline,
                          confirmPasswordController,
                          screenWidth,
                          obscureText: true,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      signUpButton(context, screenHeight, screenWidth,
                          passwordController, confirmPasswordController),
                      SizedBox(height: screenHeight * 0.02),
                      cancelButton(context, screenHeight, screenWidth),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
          buildTextField(
            hintText,
            icon,
            controller,
            screenWidth,
            obscureText: obscureText,
          ),
          Positioned(
            left: 10, // Position on the left side
            top: 5, // Maintain the vertical position
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
          if (passwordController.text.isEmpty ||
              confirmPasswordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl, // Ensure RTL alignment
                  child: const Text(
                      'יש למלא את כל השדות'), // Hebrew for "All fields must be filled"
                ),
              ),
            );

            return;
          }

          if (passwordController.text != confirmPasswordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl, // Ensure RTL alignment
                  child: const Text(
                      'הסיסמאות אינן תואמות'), // Hebrew for "Passwords do not match"
                ),
              ),
            );

            return;
          }

          User? user = await _auth.signUpWithEmailAndPassword(
              widget.email, passwordController.text);

          if (user != null) {
            Map<String, dynamic> commonData = {
              'firstName': widget.firstName,
              'lastName': widget.lastName,
              'birthDay': widget.day,
              'birthMonth': widget.month,
              'birthYear': widget.year,
              'phone': widget.phone,
              'id': widget.id,
              'email': widget.email,
            };

            if (widget.role == "מנהל") {
              await FirebaseFirestore.instance
                  .collection('Managers')
                  .doc(user.uid)
                  .set(commonData);
            } else {
              Map<String, dynamic> employeeData = {
                ...commonData,
                if (widget.truckType != 'defaultTruckType')
                  'truckType': widget.truckType,
                if (widget.truckSize != 'defaultSize')
                  'truckSize': widget.truckSize,
              };

              await FirebaseFirestore.instance
                  .collection('Employees')
                  .doc(user.uid)
                  .set(employeeData);
            }

            // Notify user about successful signup
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl,
                  child: const Text(
                      'המשתמש נוסף בהצלחה'), // Hebrew for "User added successfully"
                ),
              ),
            );

            // Navigate back to the initial route
            Navigator.popUntil(context, (route) => route.isFirst);
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl, // Ensure RTL alignment
                  child: const Text(
                      'ההרשמה נכשלה'), // Hebrew for "Failed to sign up"
                ),
              ),
            );
          }
        },
        child: Text(
          'הירשם',
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
              'ביטול',
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
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl, // Ensure RTL alignment
        child: AlertDialog(
          title: const Text('חוזק סיסמה'), // Hebrew for "Password Strength"
          content: const Text(
              'על הסיסמאות להיות באורך של לפחות 8 תווים ולכלול מספרים, סימנים, ואותיות גדולות/קטנות.'), // Hebrew translation
          actions: [
            TextButton(
              child: const Text('הבנתי'), // Hebrew for "Got it"
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget backArrow(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
        onPressed: () => Navigator.pop(context),
      );
}
