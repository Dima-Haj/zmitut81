import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Designed_helper_fields/custom_text_field.dart'; // Import your CustomTextField

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the default back arrow

        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space between arrow and title
          children: [
            Directionality(
              textDirection:
                  TextDirection.rtl, // Keep the title text RTL for Hebrew
              child: const Text(
                'שכחת סיסמה', // "Forgot Password" in Hebrew
                textAlign: TextAlign.right,
              ),
            ),
            Directionality(
              textDirection: TextDirection.ltr, // Back arrow in LTR
              child: IconButton(
                icon: const Icon(Icons.arrow_back), // Back arrow icon
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the previous page
                },
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque, // Ensures taps are detected
            onTap: () {
              FocusScope.of(context).unfocus(); // Dismiss the keyboard
            },
            child: Container(
              color: Colors.transparent, // Optional for better clarity
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'הזן את האימייל שלך כדי לקבל קישור לאיפוס סיסמה:', // "Enter your email to receive a password reset link:" in Hebrew
                  style: TextStyle(
                    fontSize: screenHeight * 0.02, // Responsive font size
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Responsive spacing
                CustomTextField(
                  hintText: 'אימייל', // "Email" in Hebrew
                  icon: Icons.email,
                  controller: emailController,
                  screenWidth: screenWidth,
                  keyboardType:
                      TextInputType.emailAddress, // Use email keyboard
                ),
                SizedBox(height: screenHeight * 0.03), // Responsive spacing
                SizedBox(
                  height: screenHeight * 0.06, // Responsive button height
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();

                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'אנא הזן את כתובת האימייל שלך', // "Please enter your email" in Hebrew
                              style: TextStyle(
                                fontSize: screenHeight * 0.02,
                              ),
                            ),
                          ),
                        );
                        return;
                      }

                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'קישור לאיפוס סיסמה נשלח!', // "Password reset email sent!" in Hebrew
                              style: TextStyle(
                                fontSize: screenHeight * 0.02,
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'שגיאה: ${e.toString()}', // "Error" in Hebrew
                              style: TextStyle(
                                fontSize: screenHeight * 0.02,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'אפס סיסמה', // "Reset Password" in Hebrew
                      style: TextStyle(
                        fontSize: screenHeight * 0.022, // Responsive font size
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
