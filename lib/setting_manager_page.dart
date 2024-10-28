// settings_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: GoogleFonts.exo2(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Settings',
                style: GoogleFonts.exo2(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Manage User Roles and Permissions'),
              leading: const Icon(Icons.admin_panel_settings),
              onTap: () {
                // Logic for managing roles
              },
            ),
            ListTile(
              title: const Text('Notification Preferences'),
              leading: const Icon(Icons.notifications),
              onTap: () {
                // Logic for setting notifications
              },
            ),
            ListTile(
              title: const Text('System Configurations'),
              leading: const Icon(Icons.settings),
              onTap: () {
                // Logic for system configurations
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Log out logic here
                },
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
