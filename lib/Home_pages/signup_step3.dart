import 'package:flutter/material.dart';
import 'package:flutter_application_1/Home_pages/signup_step4.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Designed_helper_fields/custom_text_field.dart'; // Import your CustomTextField
import 'login_page.dart'; // Import the login page for the cancel button

class SignupStep3 extends StatefulWidget {
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

  const SignupStep3({
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
  });

  @override
  _SignupStep3State createState() => _SignupStep3State();
}

class _SignupStep3State extends State<SignupStep3> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmEmailController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up resources
    emailController.dispose();
    confirmEmailController.dispose();
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
                        child: CustomTextField(
                          hintText: 'אימייל', // "Email" in Hebrew
                          icon: Icons.email,
                          controller: emailController,
                          screenWidth: screenWidth,
                          keyboardType:
                              TextInputType.emailAddress, // Use email keyboard
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Directionality(
                        textDirection:
                            TextDirection.rtl, // Set text direction to RTL
                        child: CustomTextField(
                          hintText:
                              'אישור אימייל', // Hebrew for "Confirm Email"
                          icon: Icons.email_outlined,
                          controller: confirmEmailController,
                          screenWidth: screenWidth,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      NextButton(context, screenHeight, screenWidth,
                          emailController, confirmEmailController),
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

  Widget NextButton(
    BuildContext context,
    double screenHeight,
    double screenWidth,
    TextEditingController emailController,
    TextEditingController confirmEmailController,
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
              confirmEmailController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl, // Ensure RTL alignment
                  child: const Text(
                      'יש למלא את כל השדות'), // "All fields must be filled" in Hebrew
                ),
              ),
            );

            return;
          }

          // Email validation regex
          final emailRegex = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
          if (!emailRegex.hasMatch(emailController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl, // Ensure RTL alignment
                  child: const Text(
                      'האימייל שהוזן אינו תקין'), // "Invalid email format" in Hebrew
                ),
              ),
            );
            return;
          }

          if (emailController.text != confirmEmailController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl, // Ensure RTL alignment
                  child: const Text(
                      'האימיילים אינם תואמים'), // "Emails do not match" in Hebrew
                ),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupStep4(
                firstName: widget.firstName,
                lastName: widget.lastName,
                day: widget.day,
                month: widget.month,
                year: widget.year,
                phone: widget.phone,
                id: widget.id,
                role: widget.role,
                truckType: widget.truckType,
                truckSize: widget.truckSize,
                email: emailController.text,
              ),
            ),
          );
        },
        child: Text(
          'הבא',
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

  Widget backArrow(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
        onPressed: () => Navigator.pop(context),
      );
}
