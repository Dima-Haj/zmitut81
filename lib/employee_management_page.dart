import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeManagementPage extends StatefulWidget {
  const EmployeeManagementPage({super.key});

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
    setState(() {
      employees.add({
        'name': name,
        'deliveryAssigned': 'None',
        'hoursWorked': 0,
        'performance': 'Not Evaluated',
      });
    });
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
    setState(() {
      employees.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
                'assets/images/image1.png'), // Background image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.65),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 60.0), // Space for top

              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Employee Management',
                  style: GoogleFonts.exo2(
                    fontSize: 24,
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
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // Box color
                        borderRadius: BorderRadius.circular(10),
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
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                                // Open an edit dialog for the employee
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEmployeeDialog();
        },
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: const Color.fromARGB(255, 131, 107, 81),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color.fromARGB(255, 131, 107, 81), // Border color
            width: 3.0, // Border width
          ),
          borderRadius: BorderRadius.circular(30.0), // Make it circular
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Dialog to add employee
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

  // Dialog to edit employee
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
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
