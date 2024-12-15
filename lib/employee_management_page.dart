import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeManagementPage extends StatefulWidget {
  final Map<String, dynamic>? managerDetails; // Optional manager details

  const EmployeeManagementPage({super.key, this.managerDetails});

  @override
  _EmployeeManagementPageState createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  final List<Map<String, dynamic>> employees = [
    {
      'name': 'John Doe',
      'deliveryAssigned': 'D001',
      'hoursWorked': 40,
      'performance': 'Good',
    },
    {
      'name': 'Jane Smith',
      'deliveryAssigned': 'D002',
      'hoursWorked': 35,
      'performance': 'Excellent',
    },
    {
      'name': 'Alice Johnson',
      'deliveryAssigned': 'D003',
      'hoursWorked': 30,
      'performance': 'Average',
    },
  ];

  void _addEmployee(String name) {
    if (mounted) {
      setState(() {
        employees.add({
          'name': name,
          'deliveryAssigned': 'None',
          'hoursWorked': 0,
          'performance': 'Not Evaluated',
        });
      });
    }
  }

  void _editEmployee(int index, String name, String deliveryAssigned,
      int hoursWorked, String performance) {
    setState(() {
      employees[index] = {
        'name': name,
        'deliveryAssigned': deliveryAssigned,
        'hoursWorked': hoursWorked,
        'performance': performance,
      };
    });
  }

  void _removeEmployee(int index) {
    if (mounted) {
      setState(() {
        employees.removeAt(index);
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
                child: Text(
                  'Employee Management',
                  style: GoogleFonts.exo2(
                    fontSize: screenHeight * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                      child: ListTile(
                        title: Text(
                          employee['name'],
                          style: GoogleFonts.exo2(
                            fontSize: screenHeight * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Delivery Assigned: ${employee['deliveryAssigned']}'),
                            Text(
                                'Hours Worked: ${employee['hoursWorked']} hours'),
                            Text('Performance: ${employee['performance']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                              onPressed: () {
                                _showEditEmployeeDialog(index, employee);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () {
                                _removeEmployee(index);
                              },
                            ),
                          ],
                        ),
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Employee'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Employee Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _addEmployee(nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditEmployeeDialog(int index, Map<String, dynamic> employee) {
    final nameController = TextEditingController(text: employee['name']);
    final deliveryAssignedController =
        TextEditingController(text: employee['deliveryAssigned']);
    final hoursWorkedController =
        TextEditingController(text: employee['hoursWorked'].toString());
    final performanceController =
        TextEditingController(text: employee['performance']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: deliveryAssignedController,
                decoration:
                    const InputDecoration(labelText: 'Delivery Assigned'),
              ),
              TextField(
                controller: hoursWorkedController,
                decoration: const InputDecoration(labelText: 'Hours Worked'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: performanceController,
                decoration: const InputDecoration(labelText: 'Performance'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _editEmployee(
                  index,
                  nameController.text,
                  deliveryAssignedController.text,
                  int.parse(hoursWorkedController.text),
                  performanceController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
