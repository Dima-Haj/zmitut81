import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_text_field.dart';
import 'package:flutter_application_1/date_of_birth_dropdowns.dart';
import 'package:flutter_application_1/dropdown_helpers.dart';
import 'package:flutter_application_1/firebase_auth_services.dart';
import 'package:flutter_application_1/forgot_password_page.dart';
import 'package:flutter_application_1/phone_field.dart';
import 'package:google_fonts/google_fonts.dart'; // Google fonts package
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Font Awesome package for icons
import 'package:google_sign_in/google_sign_in.dart';
import 'admin_home_page.dart';
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
  String? verificationId; // Add this field to store the verification ID
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
  bool isLoading = false;

  Future<void> handleGoogleSignIn() async {
    try {
      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Authenticate with Firebase using Google credentials
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("Google Sign-In failed.");
      }

      // Step 2: Check Firestore for the user
      final managerDoc = await FirebaseFirestore.instance
          .collection('Managers')
          .doc(user.uid)
          .get();

      final employeeDoc = await FirebaseFirestore.instance
          .collection('Employees')
          .doc(user.uid)
          .get();

      if (managerDoc.exists) {
        // Navigate to Manager Home Page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminHomePage(
              managerDetails: {
                'id': user.uid,
                'email': user.email ?? '',
                ...managerDoc.data()!,
              },
            ),
          ),
        );
      } else if (employeeDoc.exists) {
        // Navigate to Employee Home Page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EmployeeHomePage(
              employeeDetails: {
                'id': user.uid,
                'email': user.email ?? '',
                ...employeeDoc.data()!,
              },
            ),
          ),
        );
      } else {
        // Step 3: New User - Collect Role and Additional Details
        _showPhoneNumberDialog(
          context: context,
          userId: user.uid,
          email: user.email ?? '',
          displayName: googleUser.displayName ?? '',
        );
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
      );
    }
  }

  void _showPhoneNumberDialog({
    required BuildContext context,
    required String userId,
    required String email,
    required String displayName,
  }) {
    final TextEditingController firstPartPhoneController =
        TextEditingController();
    final TextEditingController secondPartPhoneController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      // Delete the user if canceled
                      try {
                        await FirebaseAuth.instance.currentUser?.delete();
                        print("User account deleted successfully.");
                      } catch (e) {
                        print("Error deleting user account: $e");
                      }
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'הזן מספר טלפון',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhoneField(
                    firstPartController: firstPartPhoneController,
                    secondPartController: secondPartPhoneController,
                  ),
                ],
              ),
              actions: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: firstPartPhoneController,
                  builder: (context, firstPartValue, child) {
                    final isFirstPartValid = firstPartValue.text.length == 1;

                    return ValueListenableBuilder<TextEditingValue>(
                      valueListenable: secondPartPhoneController,
                      builder: (context, secondPartValue, child) {
                        final isSecondPartValid =
                            secondPartValue.text.length == 7;

                        final bool isValidPhone =
                            isFirstPartValid && isSecondPartValid;

                        return ElevatedButton(
                          onPressed: isValidPhone
                              ? () {
                                  final fullPhoneNumber =
                                      "05${firstPartPhoneController.text}${secondPartPhoneController.text}";
                                  Navigator.pop(context);
                                  // Move to the next dialog to collect role
                                  _showRoleDialog(
                                    context,
                                    userId,
                                    email,
                                    displayName,
                                    fullPhoneNumber,
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isValidPhone
                                ? Colors.green
                                : Colors.grey, // Dynamic button color
                          ),
                          child: const Text('הבא',
                              textDirection: TextDirection.rtl),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRoleDialog(
    BuildContext context,
    String userId,
    String email,
    String displayName,
    String phone,
  ) {
    String? selectedRole;
    String? truckType;
    String? truckSize;
    const List<String> truckOptions = ['פלטה', 'צובר', 'תפזורת'];
    const List<String> sizeOptions = ['גדול', 'קטן'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'בחר תפקיד',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Role Dropdown
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: dropdownFieldFromList(
                      label: 'בחר תפקיד',
                      items: ['מנהל', 'שליח'],
                      currentValue: selectedRole,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedRole = value;
                          truckType =
                              null; // Reset truck type when role changes
                          truckSize = null; // Reset truck size
                        });
                      },
                      screenWidth: MediaQuery.of(context).size.width,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Truck selection for "שליח" role
                  if (selectedRole == 'שליח') ...[
                    const Text(
                      "בחר סוג משאית:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: dropdownFieldFromList(
                        label: 'בחר סוג משאית',
                        items: truckOptions,
                        currentValue: truckType,
                        onChanged: (value) {
                          setDialogState(() {
                            truckType = value!;
                            truckSize =
                                null; // Reset truck size when type changes
                          });
                        },
                        screenWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (truckType == 'פלטה' || truckType == 'תפזורת') ...[
                      const Text(
                        "בחר גודל:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textDirection: TextDirection.rtl,
                      ),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: dropdownFieldFromList(
                          label: 'בחר גודל',
                          items: sizeOptions,
                          currentValue: truckSize,
                          onChanged: (value) {
                            setDialogState(() {
                              truckSize = value!;
                            });
                          },
                          screenWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: selectedRole != null &&
                          (selectedRole == 'מנהל' ||
                              (truckType != null &&
                                  (truckType == 'פלטה' || truckType == 'תפזורת'
                                      ? truckSize != null
                                      : true)))
                      ? () {
                          Navigator.pop(context);
                          _showIdAndBirthDateDialog(
                            context,
                            selectedRole!,
                            userId,
                            email,
                            phone,
                            displayName,
                            truckType:
                                selectedRole == 'שליח' ? truckType! : null,
                            truckSize: selectedRole == 'שליח' &&
                                    (truckType! == 'פלטה' ||
                                        truckType! == 'תפזורת')
                                ? truckSize
                                : null,
                          );
                        }
                      : null,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('שמור והמשך',
                      textDirection: TextDirection.rtl),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showIdAndBirthDateDialog(
    BuildContext context,
    String selectedRole,
    String userId,
    String email,
    String phone,
    String displayName, {
    String? truckType,
    String? truckSize,
  }) {
    final TextEditingController personalIdController = TextEditingController();
    String? selectedDay;
    String? selectedMonth;
    String? selectedYear;
    bool isButtonEnabled = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void validateFields() {
              final personalIdValid = personalIdController.text.length == 9;
              final dobValid = selectedDay != null &&
                  selectedMonth != null &&
                  selectedYear != null;
              setDialogState(() {
                isButtonEnabled = personalIdValid && dobValid;
              });
            }

            // Get screen width

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'פרטי זהות ותאריך לידה',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Personal ID Input
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: CustomTextField(
                        hintText:
                            'תעודת זהות (9 ספרות)', // Hint text for the text field
                        icon: Icons.badge, // Icon to display
                        controller:
                            personalIdController, // Controller for the input
                        screenWidth: MediaQuery.of(context)
                            .size
                            .width, // Provide screen width
                      ),
                    ),
                    const SizedBox(height: 8), // Spacing

                    // Date of Birth Label
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'תאריך לידה',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    const SizedBox(height: 2), // Spacing

                    // Date of Birth Dropdowns
                    Directionality(
                      textDirection:
                          TextDirection.rtl, // Ensure Right-to-Left alignment
                      child: DateOfBirthDropdowns(
                        selectedDay: selectedDay,
                        selectedMonth: selectedMonth,
                        selectedYear: selectedYear,
                        onDayChanged: (value) {
                          setDialogState(() {
                            selectedDay = value;
                            validateFields(); // Call validation after selection
                          });
                        },
                        onMonthChanged: (value) {
                          setDialogState(() {
                            selectedMonth = value;
                            validateFields();
                          });
                        },
                        onYearChanged: (value) {
                          setDialogState(() {
                            selectedYear = value;
                            validateFields();
                          });
                        },
                        screenWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () async {
                          // Save user details to Firestore
                          Map<String, dynamic> userData = {
                            'email': email,
                            'firstName': displayName.split(' ').first,
                            'lastName':
                                displayName.split(' ').sublist(1).join(' '),
                            'role': selectedRole,
                            'phone': phone,
                            'id': personalIdController.text,
                            'birthDay': selectedDay,
                            'birthMonth': selectedMonth,
                            'birthYear': selectedYear,
                          };

                          if (selectedRole == 'שליח') {
                            userData['truckType'] = truckType ?? 'לא נבחר';
                            if (truckType == 'פלטה' || truckType == 'תפזורת') {
                              userData['truckSize'] = truckSize ?? 'לא נבחר';
                            }
                          }

                          await FirebaseFirestore.instance
                              .collection(selectedRole == 'מנהל'
                                  ? 'Managers'
                                  : 'Employees')
                              .doc(userId)
                              .set(userData);

                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => selectedRole == 'מנהל'
                                  ? AdminHomePage(managerDetails: userData)
                                  : EmployeeHomePage(employeeDetails: userData),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isButtonEnabled ? Colors.green : Colors.grey,
                  ),
                  child: const Text('שמור וסיים',
                      textDirection: TextDirection.rtl),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Method to handle login logic
  void handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enter both email and password.')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);

      if (user == null) {
        throw Exception("Authentication failed.");
      }

      // Check if the user is a Manager
      DocumentSnapshot<Map<String, dynamic>> managerDoc =
          await FirebaseFirestore.instance
              .collection('Managers')
              .doc(user.uid)
              .get();

      if (managerDoc.exists) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminHomePage(
              managerDetails: {
                'id': user.uid,
                'email': user.email ?? '',
                ...managerDoc
                    .data()!, // Spread operator to include additional fields
              },
            ),
          ),
        );
        return;
      }

      // Check if the user is an Employee
      DocumentSnapshot<Map<String, dynamic>> employeeDoc =
          await FirebaseFirestore.instance
              .collection('Employees')
              .doc(user.uid)
              .get();

      if (employeeDoc.exists) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EmployeeHomePage(
              employeeDetails: {
                'id': user.uid,
                'email': user.email ?? '',
                ...employeeDoc
                    .data()!, // Spread operator to include additional fields
              },
            ),
          ),
        );
      } else {
        throw Exception("User record not found.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
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
            top: screenHeight * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo_zmitut.png',
                height: screenHeight * 0.15, // Adjust the height as needed
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.03),

                    // "Sign in to continue" Text
                    Center(
                      child: Text(
                        'התחבר כדי להמשיך',
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
                    Directionality(
                      textDirection:
                          TextDirection.rtl, // Set text direction to RTL
                      child: MouseRegion(
                        onEnter: (_) => setState(() => isHoveredEmail = true),
                        onExit: (_) => setState(() => isHoveredEmail = false),
                        child: buildTextField(
                          'אימייל', // Hebrew for "Email"
                          Icons.email,
                          screenWidth,
                          focusNode: emailFocusNode,
                          isFocused: isEmailFocused,
                          isHovered: isHoveredEmail,
                          controller:
                              emailController, // Use controller to access text
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

// Password Field
                    Directionality(
                      textDirection:
                          TextDirection.rtl, // Set text direction to RTL
                      child: MouseRegion(
                        onEnter: (_) =>
                            setState(() => isHoveredPassword = true),
                        onExit: (_) =>
                            setState(() => isHoveredPassword = false),
                        child: buildTextField(
                          'סיסמה', // Hebrew for "Password"
                          Icons.lock,
                          screenWidth,
                          focusNode: passwordFocusNode,
                          isFocused: isPasswordFocused,
                          isHovered: isHoveredPassword,
                          obscureText: true,
                          controller: passwordController,
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          '?שכחת סיסמה',
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
                        'התחבר',
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupStep1()),
                            );
                          },
                          child: Text(
                            'הרשמה',
                            style: GoogleFonts.exo2(
                              color: const Color.fromARGB(255, 141, 126, 106),
                            ),
                          ),
                        ),
                        Text(
                          ' ?אין לך חשבון',
                          style: GoogleFonts.exo2(color: Colors.black),
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
                            FontAwesomeIcons.google,
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
        onPressed: () async {
          if (icon == FontAwesomeIcons.google) {
            await handleGoogleSignIn();
          }
          // Handle social button press here
        },
      ),
    );
  }
}
