import 'package:flutter/material.dart';
import 'package:flutter_application_1/Designed_helper_fields/custom_text_field.dart';
import 'package:flutter_application_1/Designed_helper_fields/dropdown_helpers.dart';
import 'package:flutter_application_1/Designed_helper_fields/phone_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Designed_helper_fields/date_of_birth_dropdowns.dart'; // Import the DateOfBirthDropdowns class

class EmployeeManagementPage extends StatefulWidget {
  final Map<String, dynamic>? managerDetails;

  const EmployeeManagementPage({super.key, this.managerDetails});

  @override
  _EmployeeManagementPageState createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  final List<Map<String, dynamic>> employees = [];
  final List<Map<String, dynamic>> originalEmployees = [];

  // Form Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedBirthDay;
  String? selectedBirthMonth;
  String? selectedBirthYear;
  String? selectedTruckSize;
  String? selectedTruckType;

  //bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  // Fetch employees from Firestore
  void _fetchEmployees() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Employees').get();

    final List<Map<String, dynamic>> fetchedEmployees = [];
    for (var doc in snapshot.docs) {
      final data =
          doc.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
      if (data != null) {
        final employeeData = {
          'firstName': data['firstName'],
          'lastName': data['lastName'],
          'id': data['id'],
          'phone': data['phone'],
          'birthDay': data['birthDay'],
          'birthMonth': data['birthMonth'],
          'birthYear': data['birthYear'],
          'email': data['email'],
          'truckType': data['truckType'],
        };

        // Add 'truckSize' only if it exists
        if (data.containsKey('truckSize')) {
          employeeData['truckSize'] = data['truckSize'];
        }

        fetchedEmployees.add(employeeData);
      }
    }

    setState(() {
      employees.clear();
      employees.addAll(fetchedEmployees);
      originalEmployees.addAll(fetchedEmployees);
    });
  }

  void _addEmployee(
      String firstName,
      String lastName,
      String phone,
      String email,
      String id,
      String birthDay,
      String birthMonth,
      String birthYear,
      String truckSize,
      String truckType) async {
    setState(() {
      final newEmployee = {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'id': id,
        'birthDay': birthDay,
        'birthMonth': birthMonth,
        'birthYear': birthYear,
        'truckSize': truckSize,
        'truckType': truckType,
        //'birthday': '$birthDay/$birthMonth/$birthYear', // Combined birthday
      };
      employees.add(newEmployee);
      originalEmployees.add(newEmployee); // Sync the original list
    });

    // Add the new employee to Firebase Firestore
    try {
      final employeeRef =
          FirebaseFirestore.instance.collection('Employees').doc();
      await employeeRef.set({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'id': id,
        'birthDay': birthDay,
        'birthMonth': birthMonth,
        'birthYear': birthYear,
        'truckSize': truckSize,
        'truckType': truckType,
        //'id': employeeRef.id, // Store the Firestore document ID
      });

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('העובד נוסף בהצלחה')),
      );
    } catch (e) {
      // Handle any error that may occur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('שגיאה בהוספת העובד: $e')),
      );
    }
  }

  void _removeEmployee(int index) async {
    // First, get the employee's ID before removing the employee from the list
    final removedEmployeeId = employees[index]['id'];

    // Remove the employee locally
    setState(() {
      final removedEmployee = employees.removeAt(index);
      originalEmployees.removeWhere(
          (employee) => employee['firstName'] == removedEmployee['firstName']);
    });

    // Now, remove the employee from Firebase
    try {
      // Using the employee ID to delete the document from Firestore
      await FirebaseFirestore.instance
          .collection('Employees')
          .doc(removedEmployeeId) // Use the stored ID here
          .delete();

      // A success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('העובד נמחק בהצלחה')),
      );
    } catch (e) {
      // Handle any error that may occur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('שגיאה במחיקת העובד: $e')),
      );
    }
  }

  void _editEmployee(
      int index,
      String firstName,
      String lastName,
      String phone,
      String email,
      String id, // Employee ID
      String birthDay,
      String birthMonth,
      String birthYear,
      String truckSize,
      String truckType) async {
    try {
      // Update the local employee data
      setState(() {
        final updatedEmployee = {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
          'id': id, // Keep employee ID
          'birthDay': birthDay,
          'birthMonth': birthMonth,
          'birthYear': birthYear,
          if (truckType != 'צובר') 'truckSize': truckSize,
          'truckType': truckType,
        };

        employees[index] = updatedEmployee; // Update local list with new data

        final originalIndex = originalEmployees.indexWhere((employee) =>
            employee['id'] ==
            employees[index]['id']); // Match by 'id' instead of first name
        if (originalIndex != -1) {
          originalEmployees[originalIndex] =
              updatedEmployee; // Sync with the original list
        }
      });

      // Find the Firestore document ID by searching for the employee ID
      final employeeDoc = await FirebaseFirestore.instance
          .collection('Employees')
          .where('id', isEqualTo: id) // Search by employee 'id'
          .limit(1) // We expect a single document
          .get();

      // If the employee document is found
      if (employeeDoc.docs.isNotEmpty) {
        final documentId = employeeDoc.docs.first.id; // Get the document ID

        // Now, update the employee data in Firestore using the document ID
        await FirebaseFirestore.instance
            .collection('Employees')
            .doc(documentId)
            .update({
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
          'birthDay': birthDay,
          'birthMonth': birthMonth,
          'birthYear': birthYear,
          if (truckType != 'צובר') 'truckSize': truckSize,
          'truckType': truckType,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('פרטי העובד עודכנו בהצלחה')),
        );
      } else {
        // If no employee document is found with the given ID, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('לא נמצא עובד עם ת.ז זו')),
        );
      }
    } catch (e) {
      // Handle any error that may occur during the update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('שגיאה בעדכון פרטי העובד: $e')),
      );
    }
  }

  void _showEditEmployeeDialog(int index, Map<String, dynamic> employee) {
    final firstNameController =
        TextEditingController(text: employee['firstName']);
    final lastNameController =
        TextEditingController(text: employee['lastName']);
    final fullPhoneNumber =
        employee['phone'] ?? ''; // Get the phone number or an empty string
    final String firstPart = fullPhoneNumber.substring(2, 3); // Extract "05"
    final String secondPart = fullPhoneNumber.substring(3); // Extract the rest
    final TextEditingController firstPartPhoneController =
        TextEditingController(text: firstPart);
    final TextEditingController secondPartPhoneController =
        TextEditingController(text: secondPart);

    final birthDayController =
        TextEditingController(text: employee['birthDay']);
    final birthMonthController =
        TextEditingController(text: employee['birthMonth']);
    final birthYearController =
        TextEditingController(text: employee['birthYear']);
    final emailController = TextEditingController(text: employee['email']);
    final idController = TextEditingController(text: employee['id']);
    final truckSizeController =
        TextEditingController(text: employee['truckSize']);
    final truckTypeController =
        TextEditingController(text: employee['truckType']);

    String? selectedBirthDay = employee['birthDay'];
    String? selectedBirthMonth = employee['birthMonth'];
    String? selectedBirthYear = employee['birthYear'];
    String? selectedTruckSize = employee['truckSize'];
    String? selectedTruckType = employee['truckType'];

    final _formKey = GlobalKey<FormState>(); // Form key for validation

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              title: Center(
                child: Text(
                  'עריכת עובד',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 131, 107, 81),
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey, // Link the form to the key
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'שם פרטי', // Label for "First Name" in Hebrew
                            style: const TextStyle(
                              color: Color.fromARGB(255, 131, 107, 81),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.001),
                          CustomTextField(
                            hintText:
                                'הזן שם פרטי', // Hint inside the text field
                            icon: Icons.person, // Use an appropriate icon
                            controller: firstNameController,
                            screenWidth: MediaQuery.of(context).size.width,
                          ),
                        ],
                      ),
                      if (firstNameController.text.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'שם פרטי חייב להיות מלא', // Hebrew for "First Name is required"
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'שם משפחה', // Label for "Last Name" in Hebrew
                            style: const TextStyle(
                              color: Color.fromARGB(255, 131, 107, 81),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.001),
                          CustomTextField(
                            hintText:
                                'הזן שם משפחה', // Hint inside the text field
                            icon:
                                Icons.person_outline, // Use an appropriate icon
                            controller: lastNameController,
                            screenWidth: MediaQuery.of(context).size.width,
                          ),
                        ],
                      ),
                      if (lastNameController.text.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'שם משפחה חייב להיות מלא', // Hebrew for "Last Name is required"
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ת.ז', // Label for ID in Hebrew
                            style: const TextStyle(
                              color: Color.fromARGB(255, 131, 107, 81),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.001),
                          CustomTextField(
                            hintText:
                                'הזן ת.ז כאן', // Hint inside the text field
                            icon: Icons.badge, // Icon for the field
                            controller: idController,
                            screenWidth: MediaQuery.of(context).size.width,
                            keyboardType:
                                TextInputType.number, // ID is typically numeric
                          ),
                        ],
                      ),
                      if (idController.text.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'ת.ז חייבת להיות מלאה', // Hebrew for "ID must be filled"
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'מספר טלפון', // Label for "Phone Number" in Hebrew
                            style: const TextStyle(
                              color: Color.fromARGB(255, 131, 107, 81),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.001),
                          Directionality(
                            textDirection:
                                TextDirection.ltr, // Ensure LTR alignment
                            child: PhoneField(
                              firstPartController:
                                  firstPartPhoneController, // Swap controllers
                              secondPartController: secondPartPhoneController,
                            ),
                          ),
                          if (firstPartPhoneController.text.isEmpty ||
                              secondPartPhoneController.text.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'מספר טלפון חייב להיות מלא', // Hebrew for "Phone number is required"
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'אימייל', // Label for "Email" in Hebrew
                            style: const TextStyle(
                              color: Color.fromARGB(255, 131, 107, 81),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.001),
                          CustomTextField(
                            hintText:
                                'הזן אימייל', // Hint inside the text field
                            icon: Icons.email, // Use an appropriate icon
                            controller: emailController,
                            screenWidth: MediaQuery.of(context).size.width,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          if (emailController.text.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'אימייל חייב להיות מלא', // Hebrew for "Email is required"
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Align(
                        alignment: Alignment
                            .centerRight, // Aligns the text to the right
                        child: const Text(
                          'תאריך לידה', // Label for "Birth Date" in Hebrew
                          style: TextStyle(
                            color: Color.fromARGB(255, 131, 107, 81),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.001),
                      DateOfBirthDropdowns(
                        selectedDay: selectedBirthDay,
                        selectedMonth: selectedBirthMonth,
                        selectedYear: selectedBirthYear,
                        onDayChanged: (value) {
                          setDialogState(() {
                            selectedBirthDay = value; // Update selected day
                          });
                        },
                        onMonthChanged: (value) {
                          setDialogState(() {
                            selectedBirthMonth = value; // Update selected month
                          });
                        },
                        onYearChanged: (value) {
                          setDialogState(() {
                            selectedBirthYear = value; // Update selected year
                          });
                        },
                        screenWidth: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align labels to the right
                        children: [
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'סוג משאית', // Label for "Vehicle Type" in Hebrew
                              style: TextStyle(
                                color: Color.fromARGB(255, 131, 107, 81),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.001), // Spacing between label and dropdown
                          Align(
                            alignment: Alignment.centerRight,
                            child: dropdownFieldFromList(
                              label: '', // Empty label as it's already above
                              items: [
                                'פלטה',
                                'צובר',
                                'תפזורת'
                              ], // The dropdown options
                              currentValue: selectedTruckType,
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedTruckType = value;
                                });
                              },
                              screenWidth: MediaQuery.of(context).size.width *
                                  0.8, // Adjust size
                            ),
                          ),
                          if (selectedTruckType != "צובר")
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                          if (selectedTruckType != "צובר") ...[
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'גודל משאית', // Label for "Vehicle Size" in Hebrew
                                style: TextStyle(
                                  color: Color.fromARGB(255, 131, 107, 81),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.001),
                            Align(
                              alignment: Alignment.centerRight,
                              child: dropdownFieldFromList(
                                label: '', // Empty label as it's already above
                                items: ['גדול', 'קטן'], // The dropdown options
                                currentValue: selectedTruckSize,
                                onChanged: (value) {
                                  setDialogState(() {
                                    selectedTruckSize = value;
                                  });
                                },
                                screenWidth: MediaQuery.of(context).size.width *
                                    0.8, // Adjust size
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 251, 1, 1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text('ביטול'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (firstNameController.text.isEmpty ||
                              lastNameController.text.isEmpty ||
                              firstPartPhoneController.text.isEmpty ||
                              secondPartPhoneController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              idController.text.isEmpty ||
                              selectedBirthDay == null ||
                              selectedBirthMonth == null ||
                              selectedBirthYear == null ||
                              selectedTruckType == null ||
                              ((selectedTruckType == "פלטה" ||
                                      selectedTruckType == "תפזורת") &&
                                  selectedTruckSize == null)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'אנא מלא את כל השדות'), // "Please fill in all the fields"
                              ),
                            );
                            return;
                          }
                          final nameRegex = RegExp(
                              r'^[א-תa-zA-Z\s]+$'); // Hebrew and English letters only
                          if (!nameRegex.hasMatch(firstNameController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'שם פרטי חייב להיות ללא מספרים')), // "First name must not contain numbers"
                            );
                            return;
                          }

                          if (!nameRegex.hasMatch(lastNameController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'שם משפחה חייב להיות ללא מספרים')), // "Last name must not contain numbers"
                            );
                            return;
                          }

                          // Check if phone number is exactly 10 digits
                          final phoneRegex = RegExp(r'^\d{10}$');
                          final fullPhoneNumber = '05' +
                              firstPartPhoneController.text +
                              secondPartPhoneController.text;
                          if (!phoneRegex.hasMatch(fullPhoneNumber)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'מספר הטלפון חייב להיות 10 ספרות')), // "Phone number must be 10 digits"
                            );
                            return;
                          }

                          // Check if email is valid
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(emailController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'אנא הזן אימייל תקין')), // "Please enter a valid email"
                            );
                            return;
                          }

                          // Check if ID is exactly 9 digits
                          final idRegex = RegExp(r'^\d{9}$');
                          if (!idRegex.hasMatch(idController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'תעודת זהות חייבת להיות 9 ספרות')), // "ID must be 9 digits"
                            );
                            return;
                          }
                          if (selectedBirthDay == null ||
                              selectedBirthMonth == null ||
                              selectedBirthYear == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'יש לבחור תאריך לידה מלא')), // "Select a complete birth date"
                            );
                            return;
                          }
                          if (selectedTruckType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'יש לבחור סוג רכב')), // "Select a vehicle type"
                            );
                            return;
                          }
                          if ((selectedTruckType == "פלטה" ||
                                  selectedTruckType == "תפזורת") &&
                              selectedTruckSize == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'יש לבחור גודל רכב')), // "Select a vehicle size"
                            );
                            return;
                          }
                          _editEmployee(
                            index,
                            firstNameController.text,
                            lastNameController.text,
                            '05' +
                                firstPartPhoneController.text +
                                secondPartPhoneController.text,
                            emailController.text,
                            idController.text,
                            selectedBirthDay ?? '',
                            selectedBirthMonth ?? '',
                            selectedBirthYear ?? '',
                            selectedTruckSize ?? '',
                            selectedTruckType ?? '',
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 4, 16, 249),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text('שמירה'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
                'assets/images/image1.png'), // Background image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              const Color.fromARGB(255, 42, 42, 42).withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.08),

              // Header
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'ניהול עובדים',
                        style: GoogleFonts.exo2(
                          fontSize: screenHeight * 0.024,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            employees.clear();
                            employees.addAll(
                                originalEmployees); // Reset to all employees
                          } else {
                            employees.clear();
                            employees.addAll(originalEmployees.where(
                                (employee) =>
                                    employee['firstName']
                                        .toString()
                                        .contains(value) ||
                                    (employee['id'] ?? '')
                                        .toString()
                                        .contains(value)));
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'חפש לפי שם עובד',
                        labelStyle: const TextStyle(
                          color:
                              Color.fromARGB(255, 131, 107, 81), // Brown color
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        contentPadding: const EdgeInsets.fromLTRB(
                            20.0, 30.0, 20.0, 9.0), // Adjust padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 131, 107, 81),
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 131, 107, 81),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 131, 107, 81),
                            width: 2.5,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color.fromARGB(255, 131, 107, 81),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Employee list
              Expanded(
                child: ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Container(
                      margin:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      padding: EdgeInsets.all(screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.02),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${employee['firstName']} ${employee['lastName']}',
                            style: GoogleFonts.exo2(
                              fontSize: screenHeight * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('מספר טלפון: ${employee['phone']}'),
                          Text('סוג משאית: ${employee['truckType']}'),
                          if (employee['truckType'] != 'צובר')
                            Text('גודל משאית: ${employee['truckSize']}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _showEditEmployeeDialog(index, employee);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _removeEmployee(index);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating action button to add an employee
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.02),
        child: FloatingActionButton(
          onPressed: () {
            _showAddEmployeeDialog();
          },
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          foregroundColor: const Color.fromARGB(255, 131, 107, 81),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Color.fromARGB(255, 131, 107, 81),
              width: 3.0,
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showAddEmployeeDialog() {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final TextEditingController firstPartPhoneController =
        TextEditingController();
    final TextEditingController secondPartPhoneController =
        TextEditingController();
    final birthDayController = TextEditingController();
    final birthMonthController = TextEditingController();
    final birthYearController = TextEditingController();
    final idController = TextEditingController();
    final emailController = TextEditingController();
    final truckSizeController = TextEditingController();
    final truckTypeController = TextEditingController();

    final _formKey = GlobalKey<FormState>(); // Form key for validation

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Center(
                child: Text(
                  'הוספת עובד',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 131, 107, 81),
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey, // Link the form to the key
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomTextField(
                        hintText: 'שם פרטי', // Hint inside the text field
                        icon: Icons.person, // Use an appropriate icon
                        controller: firstNameController,
                        screenWidth: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      CustomTextField(
                        hintText: 'שם משפחה', // Hint inside the text field
                        icon: Icons.person_outline, // Use an appropriate icon
                        controller: lastNameController,
                        screenWidth: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      CustomTextField(
                        hintText: 'ת.ז', // Hint inside the text field
                        icon: Icons.badge, // Icon for the field
                        controller: idController,
                        screenWidth: MediaQuery.of(context).size.width,
                        keyboardType:
                            TextInputType.number, // ID is typically numeric
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'מספר טלפון', // Label for "Phone Number" in Hebrew
                            style: const TextStyle(
                              color: Color.fromARGB(255, 131, 107, 81),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.001),
                          Directionality(
                            textDirection:
                                TextDirection.ltr, // Ensure LTR alignment
                            child: PhoneField(
                              firstPartController:
                                  firstPartPhoneController, // Swap controllers
                              secondPartController: secondPartPhoneController,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      CustomTextField(
                        hintText: 'הזן אימייל', // Hint inside the text field
                        icon: Icons.email, // Use an appropriate icon
                        controller: emailController,
                        screenWidth: MediaQuery.of(context).size.width,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Align(
                        alignment: Alignment
                            .centerRight, // Aligns the text to the right
                        child: const Text(
                          'תאריך לידה', // Label for "Birth Date" in Hebrew
                          style: TextStyle(
                            color: Color.fromARGB(255, 131, 107, 81),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.001),
                      DateOfBirthDropdowns(
                        selectedDay: selectedBirthDay,
                        selectedMonth: selectedBirthMonth,
                        selectedYear: selectedBirthYear,
                        onDayChanged: (value) {
                          setDialogState(() {
                            selectedBirthDay = value; // Update selected day
                          });
                        },
                        onMonthChanged: (value) {
                          setDialogState(() {
                            selectedBirthMonth = value; // Update selected month
                          });
                        },
                        onYearChanged: (value) {
                          setDialogState(() {
                            selectedBirthYear = value; // Update selected year
                          });
                        },
                        screenWidth: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align labels to the right
                        children: [
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'סוג רכב', // Label for "Vehicle Type" in Hebrew
                              style: TextStyle(
                                color: Color.fromARGB(255, 131, 107, 81),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.001, // Spacing
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: dropdownFieldFromList(
                              label: '', // Empty label as it's already above
                              items: [
                                'פלטה',
                                'צובר',
                                'תפזורת'
                              ], // The dropdown options
                              currentValue: selectedTruckType,
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedTruckType = value;

                                  // Clear selectedTruckSize if "צובר" is selected
                                  if (value == "צובר") {
                                    selectedTruckSize = null;
                                  }
                                });
                              },
                              screenWidth: MediaQuery.of(context).size.width *
                                  0.8, // Adjust size
                            ),
                          ),
                          if (selectedTruckType == "פלטה" ||
                              selectedTruckType == "תפזורת") ...[
                            SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.01, // Spacing
                            ),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'גודל רכב', // Label for "Vehicle Size" in Hebrew
                                style: TextStyle(
                                  color: Color.fromARGB(255, 131, 107, 81),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.001, // Spacing
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: dropdownFieldFromList(
                                label: '', // Empty label as it's already above
                                items: ['גדול', 'קטן'], // The dropdown options
                                currentValue: selectedTruckSize,
                                onChanged: (value) {
                                  setDialogState(() {
                                    selectedTruckSize = value;
                                  });
                                },
                                screenWidth: MediaQuery.of(context).size.width *
                                    0.8, // Adjust size
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 254, 4, 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text('ביטול'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (firstNameController.text.isEmpty ||
                              lastNameController.text.isEmpty ||
                              firstPartPhoneController.text.isEmpty ||
                              secondPartPhoneController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              idController.text.isEmpty ||
                              selectedBirthDay == null ||
                              selectedBirthMonth == null ||
                              selectedBirthYear == null ||
                              selectedTruckType == null ||
                              ((selectedTruckType == "פלטה" ||
                                      selectedTruckType == "תפזורת") &&
                                  selectedTruckSize == null)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'אנא מלא את כל השדות'), // "Please fill in all the fields"
                              ),
                            );
                            return;
                          }
                          final nameRegex = RegExp(
                              r'^[א-תa-zA-Z\s]+$'); // Hebrew and English letters only
                          if (!nameRegex.hasMatch(firstNameController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'שם פרטי חייב להיות ללא מספרים')), // "First name must not contain numbers"
                            );
                            return;
                          }

                          if (!nameRegex.hasMatch(lastNameController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'שם משפחה חייב להיות ללא מספרים')), // "Last name must not contain numbers"
                            );
                            return;
                          }

                          // Check if phone number is exactly 10 digits
                          final phoneRegex = RegExp(r'^\d{10}$');
                          final fullPhoneNumber = '05' +
                              firstPartPhoneController.text +
                              secondPartPhoneController.text;
                          if (!phoneRegex.hasMatch(fullPhoneNumber)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'מספר הטלפון חייב להיות 10 ספרות')), // "Phone number must be 10 digits"
                            );
                            return;
                          }

                          // Check if email is valid
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(emailController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'אנא הזן אימייל תקין')), // "Please enter a valid email"
                            );
                            return;
                          }

                          // Check if ID is exactly 9 digits
                          final idRegex = RegExp(r'^\d{9}$');
                          if (!idRegex.hasMatch(idController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'תעודת זהות חייבת להיות 9 ספרות')), // "ID must be 9 digits"
                            );
                            return;
                          }
                          if (selectedBirthDay == null ||
                              selectedBirthMonth == null ||
                              selectedBirthYear == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'יש לבחור תאריך לידה מלא')), // "Select a complete birth date"
                            );
                            return;
                          }
                          if (selectedTruckType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'יש לבחור סוג רכב')), // "Select a vehicle type"
                            );
                            return;
                          }
                          if ((selectedTruckType == "פלטה" ||
                                  selectedTruckType == "תפזורת") &&
                              selectedTruckSize == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'יש לבחור גודל רכב')), // "Select a vehicle size"
                            );
                            return;
                          }
                          _addEmployee(
                            firstNameController.text,
                            lastNameController.text,
                            '05' +
                                firstPartPhoneController.text +
                                secondPartPhoneController.text,
                            emailController.text,
                            idController.text,
                            selectedBirthDay ?? '',
                            selectedBirthMonth ?? '',
                            selectedBirthYear ?? '',
                            selectedTruckSize ?? '',
                            selectedTruckType ?? '',
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 25, 9, 251),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text('הוספה'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
