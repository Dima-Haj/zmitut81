import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_step2.dart'; // Import the next step
import 'login_page.dart'; // Import the login page

class SignupStep1 extends StatefulWidget {
  const SignupStep1({super.key});

  @override
  State<SignupStep1> createState() => _SignupStep1State();
}

class _SignupStep1State extends State<SignupStep1> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;
  String? selectedRole; // Add this to store the selected role

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

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
                'assets/images/logo_zmitut.png', // Update the logo path as needed
                height: screenHeight * 0.06,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.75,
              decoration: whiteFrame(screenWidth),
              child: SingleChildScrollView(
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
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField('First Name', Icons.person,
                              _firstNameController, screenWidth),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: buildTextField('Last Name', Icons.person_outline,
                              _lastNameController, screenWidth),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Date of Birth',
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
                    buildDateOfBirthDropdowns(screenWidth),
                    SizedBox(height: screenHeight * 0.01),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Role',
                        style: GoogleFonts.exo2(
                          textStyle: TextStyle(
                            color: const Color.fromARGB(255, 141, 126, 106),
                            fontSize: screenHeight * 0.015,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    //SizedBox(height: screenHeight * 0.005),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'Manager',
                            groupValue: selectedRole,
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value;
                              });
                            },
                            title: const Text('Manager'),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'Delivery Man',
                            groupValue: selectedRole,
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value;
                              });
                            },
                            title: const Text('Delivery Man'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    nextButton(screenWidth, screenHeight),
                    SizedBox(height: screenHeight * 0.00000000001),
                    cancelButton(context, screenHeight, screenWidth),
                    SizedBox(height: screenHeight * 0.01),
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
              offset: const Offset(0, -5))
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

  Widget buildTextField(String hintText, IconData icon,
          TextEditingController controller, double screenWidth) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: Border.all(
              color: const Color.fromARGB(255, 141, 126, 106), width: 1.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 141, 126, 106)),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: TextField(
                controller: controller,
                style: GoogleFonts.exo2(
                    textStyle:
                        const TextStyle(color: Colors.black, fontSize: 16)),
                decoration: InputDecoration(
                    hintText: hintText, border: InputBorder.none),
              ),
            ),
          ],
        ),
      );

  Widget buildDateOfBirthDropdowns(double screenWidth) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          dropdownField('Day', 1, 31, selectedDay,
              (val) => setState(() => selectedDay = val), screenWidth),
          dropdownFieldFromList('Month', months, selectedMonth,
              (val) => setState(() => selectedMonth = val), screenWidth),
          dropdownField('Year', 1980, DateTime.now().year, selectedYear,
              (val) => setState(() => selectedYear = val), screenWidth),
        ],
      );

  Widget dropdownField(String label, int start, int end, String? currentValue,
      void Function(String?) onChanged, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(
            color: const Color.fromARGB(255, 200, 200, 200), width: 1.0),
      ),
      child: DropdownButton<String>(
        value: currentValue,
        hint: Text(label),
        underline: const SizedBox(),
        items: [
          for (int i = start; i <= end; i++)
            DropdownMenuItem(value: i.toString(), child: Text(i.toString()))
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget dropdownFieldFromList(
      String label,
      List<String> items,
      String? currentValue,
      void Function(String?) onChanged,
      double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(
            color: const Color.fromARGB(255, 200, 200, 200), width: 1.0),
      ),
      child: DropdownButton<String>(
        value: currentValue,
        hint: Text(label),
        underline: const SizedBox(),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget backArrow(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        onPressed: () => Navigator.pop(context),
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
          'Next',
          style: GoogleFonts.exo2(
              color: Colors.white, fontSize: screenHeight * 0.023),
        ),
        onPressed: () {
          if (_firstNameController.text.isEmpty ||
              _lastNameController.text.isEmpty ||
              selectedDay == null ||
              selectedMonth == null ||
              selectedYear == null ||
              selectedRole == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields.')),
            );
            return;
          }
          if (_firstNameController.text.contains(RegExp(r'[0-9]')) ||
              _lastNameController.text.contains(RegExp(r'[0-9]'))) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Name must contain only letters.')),
            );
            return;
          }
          DateTime dob = DateTime(int.parse(selectedYear!),
              months.indexOf(selectedMonth!) + 1, int.parse(selectedDay!));
          if (DateTime.now().difference(dob).inDays ~/ 365 < 17) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('You must be at least 17 years old.')),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupStep2(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                day: selectedDay!,
                month: selectedMonth!,
                year: selectedYear!,
                role: selectedRole!, // Pass the role to the next step
              ),
            ),
          );
        },
      );

  Widget cancelButton(
          BuildContext context, double screenHeight, double screenWidth) =>
      Column(
        children: [
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
}
