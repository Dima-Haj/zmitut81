import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_step3.dart'; // Import the next step
import 'login_page.dart'; // Import the login page

class SignupStep2 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String day;
  final String month;
  final String year;
  final String role;
  final String truckType;
  final String truckSize;

  const SignupStep2({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.day,
    required this.month,
    required this.year,
    required this.role,
    required this.truckType,
    required this.truckSize,
  });

  @override
  State<SignupStep2> createState() => _SignupStep2State();
}

class _SignupStep2State extends State<SignupStep2> {
  final TextEditingController _firstPartPhoneController =
      TextEditingController();
  final TextEditingController _secondPartPhoneController =
      TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

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
                    SizedBox(height: screenHeight * 0.02),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'מספר טלפון',
                        style: GoogleFonts.exo2(
                          textStyle: TextStyle(
                            color: const Color.fromARGB(255, 141, 126, 106),
                            fontSize: screenHeight * 0.015,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    buildPhoneField(screenWidth),
                    SizedBox(height: screenHeight * 0.02),
                    Directionality(
                      textDirection:
                          TextDirection.rtl, // Set Right-to-Left alignment
                      child: buildTextField(
                        'ת.ז (9 ספרות)', // Hebrew for "ID (9 digits)"
                        Icons.badge,
                        _idController,
                        screenWidth,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    nextButton(screenWidth, screenHeight),
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
          )
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

  Widget buildPhoneField(double screenWidth) => Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
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
                  Icon(Icons.phone,
                      size: 18,
                      color: const Color.fromARGB(255, 141, 126, 106)),
                  const SizedBox(width: 5),
                  const Text(
                    '05',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _firstPartPhoneController,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.exo2(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        hintText: 'X',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          const Text('-'),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                border: Border.all(
                  color: const Color.fromARGB(255, 141, 126, 106),
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: _secondPartPhoneController,
                maxLength: 7,
                keyboardType: TextInputType.number,
                style: GoogleFonts.exo2(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                decoration: const InputDecoration(
                  counterText: "",
                  hintText: 'XXX-XXXX',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      );

  Widget buildTextField(
    String hintText,
    IconData icon,
    TextEditingController controller,
    double screenWidth,
  ) =>
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
                keyboardType: TextInputType.number,
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

  Widget nextButton(double screenWidth, double screenHeight) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8C7A61),
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
        ),
        child: Text(
          'הבא',
          style: GoogleFonts.exo2(
              color: Colors.white, fontSize: screenHeight * 0.023),
        ),
        onPressed: () {
          if (_secondPartPhoneController.text.length != 7 ||
              _idController.text.length != 9) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl, // Ensure RTL alignment
                  child: const Text('אנא מלא שדות חוקיים.'),
                ),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupStep3(
                firstName: widget.firstName,
                lastName: widget.lastName,
                day: widget.day,
                month: widget.month,
                year: widget.year,
                phone:
                    "05${_firstPartPhoneController.text}${_secondPartPhoneController.text}",
                id: _idController.text,
                role: widget.role,
                truckType: widget.truckType,
                truckSize: widget.truckSize,
              ),
            ),
          );
        },
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
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        onPressed: () => Navigator.pop(context),
      );
}
