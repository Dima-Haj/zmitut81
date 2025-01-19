import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          'truckSize': truckSize,
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
          'truckSize': truckSize,
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
    final phoneNumberController =
        TextEditingController(text: employee['phone']);
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
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'שם פרטי',
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 131, 107, 81),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'שם פרטי חייב להיות מלא';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'שם משפחה',
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 131, 107, 81),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'שם משפחה חייב להיות מלא';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: 'ת.ז',
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 131, 107, 81),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ת.ז חייבת להיות מלאה';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'מספר טלפון',
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 131, 107, 81),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'מספר טלפון חייב להיות מלא';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'אימייל',
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 131, 107, 81),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'אימייל חייב להיות מלא';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedBirthMonth,
                    decoration: InputDecoration(
                      labelText: 'חודש הלידה',
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 131, 107, 81),
                      ),
                    ),
                    items: [
                      'ינואר',
                      'פברואר',
                      'מרץ',
                      'אפריל',
                      'מאי',
                      'יוני',
                      'יולי',
                      'אוגוסט',
                      'ספטמבר',
                      'אוקטובר',
                      'נובמבר',
                      'דצמבר'
                    ].map((month) {
                      return DropdownMenuItem(value: month, child: Text(month));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBirthMonth = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedBirthDay,
                    decoration: InputDecoration(labelText: 'יום הלידה'),
                    items: List.generate(31, (index) {
                      final day = (index + 1).toString();
                      return DropdownMenuItem(value: day, child: Text(day));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBirthDay = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedBirthYear,
                    decoration: InputDecoration(labelText: 'שנת הלידה'),
                    items: List.generate(46, (index) {
                      final year = 1980 + index;
                      return DropdownMenuItem(
                          value: year.toString(), child: Text(year.toString()));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBirthYear = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedTruckSize,
                    decoration: InputDecoration(labelText: 'גודל רכב'),
                    items: ['גדול', 'קטן'].map((size) {
                      return DropdownMenuItem(value: size, child: Text(size));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTruckSize = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedTruckType,
                    decoration: InputDecoration(labelText: 'סוג רכב'),
                    items: ['פלטה', 'צובר', 'תפזורת'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTruckType = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 131, 107, 81),
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
                      _editEmployee(
                        index,
                        firstNameController.text,
                        lastNameController.text,
                        phoneNumberController.text,
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
                    backgroundColor: const Color.fromARGB(255, 131, 107, 81),
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
                          if (employee['truckSize'] != null)
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
    final phoneNumberController = TextEditingController();
    final birthDayController = TextEditingController();
    final birthMonthController = TextEditingController();
    final birthYearController = TextEditingController();
    final idController = TextEditingController();
    final emailConroller = TextEditingController();
    final truckSizeController = TextEditingController();
    final truckTypeController = TextEditingController();

    final _formKey = GlobalKey<FormState>(); // Form key for validation

    showDialog(
      context: context,
      builder: (context) {
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
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(labelText: 'שם פרטי'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'שם פרטי חייב להיות מלא';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: 'שם משפחה'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'שם משפחה חייב להיות מלא';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: idController,
                    decoration: InputDecoration(labelText: 'ת.ז'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ת.ז חייבת להיות מלאה';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(labelText: 'מספר טלפון'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'מספר טלפון חייב להיות מלא';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailConroller,
                    decoration: InputDecoration(labelText: 'אימייל'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'אימייל חייב להיות מלא';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedBirthMonth,
                    decoration: InputDecoration(labelText: 'חודש הלידה'),
                    items: [
                      'ינואר',
                      'פברואר',
                      'מרץ',
                      'אפריל',
                      'מאי',
                      'יוני',
                      'יולי',
                      'אוגוסט',
                      'ספטמבר',
                      'אוקטובר',
                      'נובמבר',
                      'דצמבר'
                    ].map((month) {
                      return DropdownMenuItem(value: month, child: Text(month));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBirthMonth = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedBirthDay,
                    decoration: InputDecoration(labelText: 'יום הלידה'),
                    items: List.generate(31, (index) {
                      final day = (index + 1).toString();
                      return DropdownMenuItem(value: day, child: Text(day));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBirthDay = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedBirthYear,
                    decoration: InputDecoration(labelText: 'שנת הלידה'),
                    items: List.generate(46, (index) {
                      final year = 1980 + index;
                      return DropdownMenuItem(
                          value: year.toString(), child: Text(year.toString()));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBirthYear = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedTruckSize,
                    decoration: InputDecoration(labelText: 'גודל רכב'),
                    items: ['גדול', 'קטן'].map((size) {
                      return DropdownMenuItem(value: size, child: Text(size));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTruckSize = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedTruckType,
                    decoration: InputDecoration(labelText: 'סוג רכב'),
                    items: ['פלטה', 'צובר', 'תפזורת'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTruckType = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 131, 107, 81),
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
                      _addEmployee(
                        firstNameController.text,
                        lastNameController.text,
                        phoneNumberController.text,
                        emailConroller.text,
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
                    backgroundColor: const Color.fromARGB(255, 131, 107, 81),
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
  }
}
