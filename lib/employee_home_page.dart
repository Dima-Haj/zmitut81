import 'package:flutter/material.dart';
import 'stopwatch_widget.dart';
import 'timesheet_page.dart';
import 'clients_for_today_page.dart';

class EmployeeHomePage extends StatefulWidget {
  final Map<String, dynamic> employeeDetails;

  const EmployeeHomePage({super.key, required this.employeeDetails});

  @override
  EmployeeHomePageState createState() => EmployeeHomePageState();
}

class EmployeeHomePageState extends State<EmployeeHomePage> {
  int _selectedIndex = 0;
  final Map<DateTime, int> _shiftRecords = {};
  final GlobalKey<TimesheetPageState> _timesheetKey = GlobalKey();

  void _onShiftEnd(DateTime endDate, int durationInSeconds) {
    setState(() {
      _shiftRecords[endDate] = durationInSeconds;
    });

    // Update TimesheetPage when shift ends
    _timesheetKey.currentState?.fetchShiftRecords();
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

    List<Widget> widgetOptions = <Widget>[
      StopwatchWidget(
        onShiftEnd: _onShiftEnd,
        employeeId: widget.employeeDetails['id'], // Pass the employeeId here
      ),
      ClientsForTodayPage(),
      TimesheetPage(
        key: _timesheetKey,
        employeeDetails: widget.employeeDetails,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/image1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.7),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.07,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo_zmitut.png',
                    height: screenHeight * 0.06,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Hello, ${widget.employeeDetails['firstName']}!',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping), label: 'Deliveries'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Timesheet'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}
