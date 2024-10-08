import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _firstPartController =
      TextEditingController(text: '05'); // Pre-filled with '05'
  final TextEditingController _secondPartController =
      TextEditingController(); // For the remaining 7 digits

  // Date of Birth Lists
  List<String> days = List.generate(31, (index) => (index + 1).toString());
  List<String> months = [
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
    'December'
  ];
  List<String> years =
      List.generate(100, (index) => (DateTime.now().year - index).toString());

  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;

  @override
  void initState() {
    super.initState();

    // Listen to changes in the first text field and restrict deletion of '05'
    _firstPartController.addListener(() {
      if (_firstPartController.text.length < 2) {
        // If less than "05", force it to stay "05"
        _firstPartController.text = '05';
        _firstPartController.selection = TextSelection.fromPosition(
            TextPosition(offset: _firstPartController.text.length));
      } else if (!_firstPartController.text.startsWith('05')) {
        // Force the text to always start with "05"
        _firstPartController.text =
            '05${_firstPartController.text.substring(2)}';
        _firstPartController.selection = TextSelection.fromPosition(
            TextPosition(offset: _firstPartController.text.length));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Resizes the content when the keyboard appears
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
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.05), // Add some top space

                    // Title "Create an Account"
                    Center(
                      child: Text(
                        'Create an Account',
                        style: GoogleFonts.exo2(
                          color: Colors.white,
                          fontSize: screenHeight * 0.04, // Adjusted font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    // Row for First Name and Last Name
                    Row(
                      children: [
                        // First Name Field
                        Expanded(
                          child: TextField(
                            style: const TextStyle(
                                color: Colors.white), // Text color while typing
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              labelStyle: GoogleFonts.exo2(color: Colors.white),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            width:
                                screenWidth * 0.03), // Space between the fields

                        // Last Name Field
                        Expanded(
                          child: TextField(
                            style: const TextStyle(
                                color: Colors.white), // Text color while typing
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              labelStyle: GoogleFonts.exo2(color: Colors.white),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03), // Space between rows

                    // Phone Number Label
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.001),
                      child: Text(
                        'Phone Number',
                        style: GoogleFonts.exo2(
                          color: Colors.white,
                          fontSize: screenHeight *
                              0.013, // Adjusted font size for the label
                        ),
                      ),
                    ),

                    // Phone Number Field (divided into two parts with a dash)
                    Row(
                      children: [
                        // First part (uneditable "05", but can add a third digit)
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _firstPartController,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            style: const TextStyle(
                                color: Colors.white), // Text color while typing
                            decoration: InputDecoration(
                              counterText: '', // Removes character counter
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.length == 3) {
                                FocusScope.of(context)
                                    .nextFocus(); // Automatically move to next field
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02),
                          child: Text(
                            '-',
                            style: GoogleFonts.exo2(
                                color: Colors.white,
                                fontSize: screenHeight * 0.03),
                          ),
                        ),
                        // Second part (7 digits)
                        Expanded(
                          flex: 7,
                          child: TextField(
                            controller: _secondPartController,
                            keyboardType: TextInputType.number,
                            maxLength: 7,
                            style: const TextStyle(
                                color: Colors.white), // Text color while typing
                            decoration: InputDecoration(
                              counterText: '', // Removes character counter
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Date of Birth Label
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                      child: Text(
                        'Date of Birth',
                        style: GoogleFonts.exo2(
                          color: Colors.white,
                          fontSize: screenHeight *
                              0.02, // Adjusted font size for the label
                        ),
                      ),
                    ),

                    // Date of Birth Dropdown (Day, Month, Year)
                    Row(
                      children: [
                        // Day Dropdown
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: selectedDay,
                            dropdownColor: Colors.black,
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            hint: Text('Day',
                                style: GoogleFonts.exo2(color: Colors.white)),
                            items: days.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedDay = newValue;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                            width:
                                screenWidth * 0.03), // Space between dropdowns

                        // Month Dropdown
                        Expanded(
                          flex: 5,
                          child: DropdownButtonFormField<String>(
                            value: selectedMonth,
                            dropdownColor: Colors.black,
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            hint: Text('Month',
                                style: GoogleFonts.exo2(color: Colors.white)),
                            items: months.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedMonth = newValue;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),

                        // Year Dropdown
                        Expanded(
                          flex: 4,
                          child: DropdownButtonFormField<String>(
                            value: selectedYear,
                            dropdownColor: Colors.black,
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            hint: Text('Year',
                                style: GoogleFonts.exo2(color: Colors.white)),
                            items: years.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedYear = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Email Field
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                          color: Colors.white), // Text color while typing
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.exo2(color: Colors.white),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Password Field
                    TextField(
                      obscureText: true,
                      style: const TextStyle(
                          color: Colors.white), // Text color while typing
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.exo2(color: Colors.white),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Create Account Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Handle sign-up logic here
                      },
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.exo2(
                          color: const Color(0xFFD6985D),
                          fontSize: screenHeight * 0.025,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        // Pop the current page (CreateAccountPage) and return to the previous page (LoginPage)
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.exo2(
                          color: Colors.white,
                          fontSize: screenHeight * 0.02,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
