import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Home_pages/Login_page.dart';

class TimesheetPage extends StatefulWidget {
  final Map<String, dynamic> employeeDetails;

  const TimesheetPage({super.key, required this.employeeDetails});

  @override
  TimesheetPageState createState() => TimesheetPageState();
}

class TimesheetPageState extends State<TimesheetPage> {
  Map<DateTime, int> shiftRecords = {}; // Store shift durations
  Map<String, Map<DateTime, int>> monthlyShiftRecords = {}; // Grouped by month
  String selectedMonthKey = ''; // Current selected month
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true; // Show loading state
  bool _noRecords = false; // No records flag

  @override
  void initState() {
    super.initState();
    fetchShiftRecords();
  }

  /// Fetches shift records from Firestore and groups them by month.
  Future<void> fetchShiftRecords() async {
    setState(() {
      _isLoading = true;
      _noRecords = false;
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
          _noRecords = true;
        });
        return;
      }

      final tempShiftRecords = <String, Map<DateTime, int>>{};

      for (var doc in workShiftsCollection.docs) {
        Map<String, dynamic> data = doc.data();
        if (data.containsKey('start') && data.containsKey('end')) {
          try {
            DateTime startTime = DateTime.parse(data['start']);
            DateTime endTime = DateTime.parse(data['end']);
            Duration shiftDuration = endTime.difference(startTime);

            final monthKey =
                '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}';
            if (!tempShiftRecords.containsKey(monthKey)) {
              tempShiftRecords[monthKey] = {};
            }
            tempShiftRecords[monthKey]![startTime] = shiftDuration.inSeconds;
          } catch (e) {
            // Handle parsing errors silently
          }
        }
      }

      final currentMonthKey =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

      setState(() {
        monthlyShiftRecords = tempShiftRecords;
        selectedMonthKey = monthlyShiftRecords.containsKey(currentMonthKey)
            ? currentMonthKey
            : tempShiftRecords.keys.first;
      });
    } catch (e) {
      // Handle fetch errors
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Formats the month key for display (e.g., "2024-05" to "05/2024").
  String _formatMonthKey(String monthKey) {
    final parts = monthKey.split('-');
    return '${parts[1]}/${parts[0]}'; // MM/YYYY
  }

  /// Formats the duration for display.
  String _formatDuration(int durationInSeconds) {
    int hours = durationInSeconds ~/ 3600;
    int minutes = (durationInSeconds % 3600) ~/ 60;
    return '${hours.toString().padLeft(2, '0')} ש ${minutes.toString().padLeft(2, '0')} ד';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    final selectedShiftRecords = monthlyShiftRecords[selectedMonthKey] ?? {};

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
          top: screenHeight * 0.07,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159), // Rotate 180 degrees
                  child: const Icon(Icons.logout, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo_zmitut.png',
                    height: screenHeight * 0.06,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.1), // Placeholder for spacing
            ],
          ),
        ),

        // Foreground content
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100), // Space for the logo

              Center(
                child: Text(
                  'דו"ח שעות חודשי',
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Month Selector Dropdown
              if (monthlyShiftRecords.isNotEmpty)
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align to the right
                  children: [
                    Directionality(
                      textDirection:
                          TextDirection.rtl, // Optional: For RTL text direction
                      child: DropdownButton<String>(
                        value: selectedMonthKey,
                        onChanged: (value) {
                          setState(() {
                            selectedMonthKey = value!;
                          });
                        },
                        dropdownColor: Colors.black,
                        items: monthlyShiftRecords.keys.map((monthKey) {
                          return DropdownMenuItem(
                            value: monthKey,
                            child: Text(
                              _formatMonthKey(monthKey),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Display shift records or loading indicator
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : selectedShiftRecords.isEmpty
                        ? Center(
                            child: Text(
                              '.לא נמצאו רישומי משמרות לחודש זה',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: selectedShiftRecords.length,
                            itemBuilder: (context, index) {
                              DateTime date =
                                  selectedShiftRecords.keys.elementAt(index);
                              int duration = selectedShiftRecords[date]!;
                              return Directionality(
                                textDirection: TextDirection
                                    .rtl, // Set text direction to RTL
                                child: ListTile(
                                  title: Text(
                                    '${date.day}/${date.month}/${date.year}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    _formatDuration(duration),
                                    style: TextStyle(color: Colors.grey[300]),
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              // Total hours worked for the selected month
              const Divider(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Align(
                  alignment:
                      Alignment.centerRight, // Align the text to the right side
                  child: Directionality(
                    textDirection:
                        TextDirection.rtl, // Set text direction to RTL
                    child: Text(
                      'סה"כ שעות: ${_formatDuration(selectedShiftRecords.values.fold(0, (sum1, item) => sum1 + item))}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
