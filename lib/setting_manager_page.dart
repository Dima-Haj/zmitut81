// settings_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('הגדרות',
            style: GoogleFonts.exo2(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('ניהול תפקידי משתמש והרשאות'),
              leading: const Icon(Icons.admin_panel_settings),
              onTap: () {
                // Logic for managing roles
              },
            ),
            ListTile(
              title: const Text('העדפות התראות'),
              leading: const Icon(Icons.notifications),
              onTap: () {
                // Logic for setting notifications
              },
            ),
            ListTile(
              title: const Text('הגדרות מערכת'),
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
