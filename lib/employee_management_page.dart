import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeManagementPage extends StatefulWidget {
  final Map<String, dynamic>? managerDetails; // Optional manager details

  const EmployeeManagementPage({super.key, this.managerDetails});

  @override
  _EmployeeManagementPageState createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  final List<Map<String, dynamic>> employees = [];
  final List<Map<String, dynamic>> originalEmployees = [];

  void _addEmployee(String name, String phoneNumber, bool availability) {
    if (mounted) {
      setState(() {
        final newEmployee = {
          'name': name,
          'phoneNumber': phoneNumber,
          'availability': availability,
          'deliveryDetails': null, // Initially no delivery details
        };
        employees.add(newEmployee);
        originalEmployees.add(newEmployee); // Sync the original list
      });
    }
  }

  void _assignDelivery(int index, Map<String, dynamic> deliveryDetails) {
    setState(() {
      employees[index]['availability'] = false;
      employees[index]['deliveryDetails'] = deliveryDetails;
    });
  }

  void _showOnMap(int index) {
    // Placeholder for future functionality
    print("הצג משלוח במפה לעובד: ${employees[index]['name']}");
  }

  void _editEmployee(
      int index, String name, String phoneNumber, bool availability) {
    setState(() {
      final updatedEmployee = {
        'name': name,
        'phoneNumber': phoneNumber,
        'availability': availability,
        'deliveryDetails': employees[index]
            ['deliveryDetails'], // Retain delivery details
      };
      employees[index] = updatedEmployee;
      final originalIndex = originalEmployees.indexWhere(
          (employee) => employee['name'] == employees[index]['name']);
      if (originalIndex != -1) {
        originalEmployees[originalIndex] =
            updatedEmployee; // Sync original list
      }
    });
  }

  void _showAssignDeliveryDialog(int index) {
    final deliveryNumberController = TextEditingController();
    final destinationController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          backgroundColor:
              const Color.fromARGB(255, 255, 255, 255), // White background
          title: Center(
            child: Text(
              'להקצות משלוח',
              style: TextStyle(
                color: const Color.fromARGB(255, 131, 107, 81), // Brown color
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Delivery Number Field
                TextField(
                  controller: deliveryNumberController,
                  decoration: InputDecoration(
                    labelText: 'מספר משלוח',
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(
                          255, 131, 107, 81), // Brown label color
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    filled: true,
                    fillColor: const Color.fromARGB(
                        255, 245, 245, 245), // Light gray background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color:
                            Color.fromARGB(255, 131, 107, 81), // Border color
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Destination Field
                TextField(
                  controller: destinationController,
                  decoration: InputDecoration(
                    labelText: 'יעד',
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 131, 107, 81),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    filled: true,
                    fillColor: const Color.fromARGB(255, 245, 245, 245),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Date Field
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'תאריך',
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 131, 107, 81),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    filled: true,
                    fillColor: const Color.fromARGB(255, 245, 245, 245),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Time Field
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'שעה',
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 131, 107, 81),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    filled: true,
                    fillColor: const Color.fromARGB(255, 245, 245, 245),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 131, 107, 81),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 131, 107, 81),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text('ביטול'),
            ),
            SizedBox(width: 60),
            ElevatedButton(
              onPressed: () {
                _assignDelivery(index, {
                  'deliveryNumber': deliveryNumberController.text,
                  'destination': destinationController.text,
                  'date': dateController.text,
                  'time': timeController.text,
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 131, 107, 81),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text('להקצות'),
            ),
          ],
        );
      },
    );
  }

  void _removeEmployee(int index) {
    if (mounted) {
      setState(() {
        final removedEmployee = employees.removeAt(index);
        originalEmployees.removeWhere(
            (employee) => employee['name'] == removedEmployee['name']);
      });
    }
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
                        'ניהול עובדים ומשלוחים',
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
                                    employee['name']
                                        .toString()
                                        .contains(value) ||
                                    (employee['deliveryDetails']
                                                ?['deliveryNumber'] ??
                                            '')
                                        .toString()
                                        .contains(value)));
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'חפש לפי שם עובד או מספר משלוח',
                        labelStyle: const TextStyle(
                          color:
                              Color.fromARGB(255, 131, 107, 81), // Brown color
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior
                            .auto, // Ensure label floats properly
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
                            employee['name'],
                            style: GoogleFonts.exo2(
                              fontSize: screenHeight * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('מספר טלפון: ${employee['phoneNumber']}'),
                          Text(
                              'פנוי: ${employee['availability'] ? 'כן' : 'לא'}'),
                          if (employee['deliveryDetails'] != null)
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: const Color.fromARGB(255,
                                          255, 255, 255), // White background
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      title: Center(
                                        child: Text(
                                          'פרטי משלוח',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromARGB(
                                                255,
                                                131,
                                                107,
                                                81), // Match your theme
                                          ),
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'מספר משלוח: ${employee['deliveryDetails']['deliveryNumber']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'יעד: ${employee['deliveryDetails']['destination']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'תאריך: ${employee['deliveryDetails']['date']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'שעה: ${employee['deliveryDetails']['time']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .end, // Align button to the right
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255,
                                                        131,
                                                        107,
                                                        81), // Match theme
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                              ),
                                              child: const Text('סגור'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'משלוח: ${employee['deliveryDetails']['deliveryNumber']}',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              employee['availability']
                                  ? ElevatedButton(
                                      onPressed: () {
                                        _showAssignDeliveryDialog(index);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 255, 255, 255), // White
                                        foregroundColor: const Color.fromARGB(
                                            255, 131, 107, 81), // Brown
                                        side: const BorderSide(
                                          color: Color.fromARGB(255, 131, 107,
                                              81), // Border color
                                          width: 2.0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              30.0), // Rounded corners
                                        ),
                                      ),
                                      child: const Text('להקצות משלוח'),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        _showOnMap(index);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 255, 255, 255), // White
                                        foregroundColor: const Color.fromARGB(
                                            255, 131, 107, 81), // Brown
                                        side: const BorderSide(
                                          color: Color.fromARGB(255, 131, 107,
                                              81), // Border color
                                          width: 2.0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              30.0), // Rounded corners
                                        ),
                                      ),
                                      child: const Text('הצג במפה'),
                                    ),
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
    final nameController = TextEditingController();
    final phoneNumberController = TextEditingController();
    bool availability = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color.fromARGB(255, 255, 255, 255), // White background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Center(
            child: Text(
              'הוספת עובד',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    const Color.fromARGB(255, 131, 107, 81), // Match your theme
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'שם העובד',
                  labelStyle: const TextStyle(
                    color:
                        Color.fromARGB(255, 131, 107, 81), // Match your theme
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color:
                          Color.fromARGB(255, 131, 107, 81), // Match your theme
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 245, 245, 245),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'מספר טלפון',
                  labelStyle: const TextStyle(
                    color:
                        Color.fromARGB(255, 131, 107, 81), // Match your theme
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color:
                          Color.fromARGB(255, 131, 107, 81), // Match your theme
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 245, 245, 245),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'פנוי:',
                    style: TextStyle(
                      color: Color.fromARGB(255, 131, 107, 81),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Switch(
                        value: availability,
                        onChanged: (value) {
                          setState(() {
                            availability = value;
                          });
                        },
                        activeColor: const Color.fromARGB(
                            255, 131, 107, 81), // Match your theme
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align buttons to the right
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
                    _addEmployee(
                      nameController.text,
                      phoneNumberController.text,
                      availability,
                    );
                    Navigator.of(context).pop();
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

  void _showEditEmployeeDialog(int index, Map<String, dynamic> employee) {
    final nameController = TextEditingController(text: employee['name']);
    final phoneNumberController =
        TextEditingController(text: employee['phoneNumber']);
    bool availability = employee['availability'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          backgroundColor:
              const Color.fromARGB(255, 255, 255, 255), // White background
          title: Center(
            child: Text(
              'עריכת עובד',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 131, 107, 81), // Brown color
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'שם',
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 131, 107, 81), // Brown color
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 131, 107, 81), // Brown border
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 131, 107, 81), // Brown border
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 131, 107, 81), // Brown border
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor:
                      const Color.fromARGB(255, 240, 240, 240), // Light gray
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'מספר טלפון',
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 131, 107, 81), // Brown color
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 131, 107, 81), // Brown border
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 131, 107, 81), // Brown border
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 131, 107, 81), // Brown border
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor:
                      const Color.fromARGB(255, 240, 240, 240), // Light gray
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'פנוי:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 131, 107, 81), // Brown color
                    ),
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Switch(
                        value: availability,
                        onChanged: (value) {
                          setState(() {
                            availability = value;
                          });
                        },
                        activeColor: const Color.fromARGB(
                            255, 131, 107, 81), // Match your theme
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor:
                    const Color.fromARGB(255, 131, 107, 81), // Brown color
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                _editEmployee(
                  index,
                  nameController.text,
                  phoneNumberController.text,
                  availability,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 131, 107, 81), // Brown button
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'שמירה',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
