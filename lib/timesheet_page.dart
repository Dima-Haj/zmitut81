import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimesheetPage extends StatefulWidget {
  final Map<String, dynamic> employeeDetails;

  const TimesheetPage({super.key, required this.employeeDetails});

  @override
  TimesheetPageState createState() => TimesheetPageState();
}

class TimesheetPageState extends State<TimesheetPage> {
  Map<DateTime, int> shiftRecords = {}; // To store calculated shift durations
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true; // To show loading state
  bool _noRecords = false; // Flag to indicate no shift records

  @override
  void initState() {
    super.initState();
    fetchShiftRecords();
  }

  /// Fetches shift records from Firestore.
  Future<void> fetchShiftRecords() async {
    setState(() {
      _isLoading = true; // Start loading
      _noRecords = false; // Reset no records flag
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
          return;
      }

      final workShiftsCollection = await FirebaseFirestore.instance
          .collection('Employees')
          .doc(user.uid)
          .collection('work_shifts')
          .orderBy('start', descending: true)
          .get();

      if (workShiftsCollection.docs.isEmpty) {
        setState(() {
          shiftRecords = {};
          _noRecords = true; // No records available
        });
        return;
      }

      final tempShiftRecords = <DateTime, int>{};

      for (var doc in workShiftsCollection.docs) {
        Map<String, dynamic> data = doc.data();
        if (data.containsKey('start') && data.containsKey('end')) {
          try {
            DateTime startTime = DateTime.parse(data['start']);
            DateTime endTime = DateTime.parse(data['end']);
            Duration shiftDuration = endTime.difference(startTime);

            tempShiftRecords[startTime] = shiftDuration.inSeconds;
          } catch (e) {
            //empty
          }
        } else {
          //empty
        }
      }

      setState(() {
        shiftRecords = tempShiftRecords;
      });
    } catch (e) {
      //empty
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  /// Formats the duration for display.
  String _formatDuration(int durationInSeconds) {
    int hours = durationInSeconds ~/ 3600;
    int minutes = (durationInSeconds % 3600) ~/ 60;
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Stack(
      children: [
        // Background Image
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

        // Logo Positioned at the top center
        Positioned(
          top: screenHeight * 0.03,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/images/logo_zmitut.png',
              height: screenHeight * 0.06,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Foreground content (shift records and employee details)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100), // Space for the logo

              Center(
                child: Text(
                  'Monthly Timesheet',
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Display shift records or loading indicator
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _noRecords
                        ? Center(
                            child: Text(
                              'No shift records found.',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: shiftRecords.length,
                            itemBuilder: (context, index) {
                              DateTime date = shiftRecords.keys.elementAt(index);
                              int duration = shiftRecords[date]!;
                              return ListTile(
                                title: Text(
                                  '${date.day}/${date.month}/${date.year}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  _formatDuration(duration),
                                  style: TextStyle(color: Colors.grey[300]),
                                ),
                              );
                            },
                          ),
              ),

              // Total hours worked
              const Divider(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Total Hours: ${_formatDuration(shiftRecords.values.fold(0, (sum, item) => sum + item))}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
