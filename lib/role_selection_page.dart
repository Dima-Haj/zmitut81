import 'package:flutter/material.dart';

class RoleSelectionPage extends StatelessWidget {
  final Function(String role) onRoleSelected;

  const RoleSelectionPage({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
        backgroundColor: const Color.fromARGB(255, 141, 126, 106),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => onRoleSelected('Manager'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child:
                  const Text('I am a Manager', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => onRoleSelected('Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: const Text('I am an Employee',
                  style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
