import 'package:flutter/material.dart';
import 'stopwatch_widget.dart';
import 'timesheet_page.dart'; // Import the TimesheetPage

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  EmployeeHomePageState createState() => EmployeeHomePageState();
}

class EmployeeHomePageState extends State<EmployeeHomePage> {
  int _selectedIndex = 0;
  final Map<DateTime, int> _shiftRecords = {}; // Record of hours worked

  // Method to handle when a shift ends
  void _onShiftEnd(DateTime endDate, int durationInSeconds) {
    setState(() {
      _shiftRecords[endDate] = durationInSeconds;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;

    // Define widget options here to access the _shiftRecords and _onShiftEnd
    List<Widget> widgetOptions = <Widget>[
      StopwatchWidget(onShiftEnd: _onShiftEnd), // Home tab with StopwatchWidget
      const Text('Map Content'), // Placeholder for Map tab content
      TimesheetPage(shiftRecords: _shiftRecords), // Timesheet tab content
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            height: screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/image1.png'), // Add your image path
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.7),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Logo Positioned at the top center
          Positioned(
            top: screenHeight * 0.03,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo_zmitut.png', // Add your logo path
                height: screenHeight * 0.06,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Foreground Content
          Center(
            child: widgetOptions.elementAt(_selectedIndex), // Display selected tab content
          ),
        ],
      ),

      // Bottom Navigation Bar with solid gray background and shadow
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800], // Solid gray background color
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // Shadow color
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -3), // Shadow position
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Timesheet', // Renamed from Schedule to Timesheet
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.white, // Set unselected icon color for better contrast
          onTap: _onItemTapped,
          backgroundColor: const Color.fromARGB(255, 7, 7, 7), // Same solid gray background color
        ),
      ),
    );
  }
}
