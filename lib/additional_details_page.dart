import 'package:flutter/material.dart';

class AdditionalDetailsPage extends StatefulWidget {
  final String role; // "Manager" or "Employee"
  final Function(Map<String, dynamic>) onSaveDetails;

  const AdditionalDetailsPage({
    super.key,
    required this.role,
    required this.onSaveDetails,
  });

  @override
  _AdditionalDetailsPageState createState() => _AdditionalDetailsPageState();
}

class _AdditionalDetailsPageState extends State<AdditionalDetailsPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDayController = TextEditingController();
  final TextEditingController birthMonthController = TextEditingController();
  final TextEditingController birthYearController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String truckType = ""; // Only for Employees
  String truckSize = ""; // Additional dropdown for 'תפזורת' or 'פלטה'

  final List<String> truckOptions = ['פלטה', 'צובר', 'תפזורת'];
  final List<String> sizeOptions = ['גדול', 'קטן'];

  @override
  Widget build(BuildContext context) {
    bool isEmployee = widget.role == 'Employee';

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter ${widget.role} Details'),
        backgroundColor: const Color.fromARGB(255, 141, 126, 106),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField("First Name", firstNameController),
              const SizedBox(height: 10),
              _buildTextField("Last Name", lastNameController),
              const SizedBox(height: 10),
              _buildTextField("Day of Birth", birthDayController),
              _buildTextField("Month of Birth", birthMonthController),
              _buildTextField("Year of Birth", birthYearController),
              _buildTextField("Phone Number", phoneController),
              const SizedBox(height: 20),

              // Employee-only Truck Details
              if (isEmployee) ...[
                const Text(
                  "Select Truck Type:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                DropdownButton<String>(
                  value: truckType.isNotEmpty ? truckType : null,
                  hint: const Text("Choose Truck Type"),
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      truckType = value!;
                      truckSize = ""; // Reset size when type changes
                    });
                  },
                  items: truckOptions
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                ),
                if (truckType == 'פלטה' || truckType == 'תפזורת') ...[
                  const Text(
                    "Select Size:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  DropdownButton<String>(
                    value: truckSize.isNotEmpty ? truckSize : null,
                    hint: const Text("Choose Size"),
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        truckSize = value!;
                      });
                    },
                    items: sizeOptions
                        .map((size) => DropdownMenuItem(
                              value: size,
                              child: Text(size),
                            ))
                        .toList(),
                  ),
                ],
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _saveDetails,
                child: const Text(
                  'Save Details',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _saveDetails() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    Map<String, dynamic> details = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'birthDay': birthDayController.text,
      'birthMonth': birthMonthController.text,
      'birthYear': birthYearController.text,
      'phone': phoneController.text,
    };

    if (widget.role == 'Employee') {
      details['truckType'] = truckType;
      if (truckType == 'פלטה' || truckType == 'תפזורת') {
        details['truckSize'] = truckSize;
      }
    }

    widget.onSaveDetails(details);
  }
}
