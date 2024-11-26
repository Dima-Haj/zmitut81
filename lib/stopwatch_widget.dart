import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'timesheet_page.dart';

class StopwatchWidget extends StatefulWidget {
  final Function(DateTime, int) onShiftEnd;
  final String employeeId;

  const StopwatchWidget({
    super.key,
    required this.onShiftEnd,
    required this.employeeId,
  });

  @override
  StopwatchWidgetState createState() => StopwatchWidgetState();
}

class StopwatchWidgetState extends State<StopwatchWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer = Timer(Duration.zero, () {});
  int _seconds = 0;
  bool _isRunning = false;
  bool _isShiftStarted = false;
  DateTime? _startTime;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _loadShiftState();
  }

  Future<void> _loadShiftState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStartTime = prefs.getString('start_time');
    final savedSeconds = prefs.getInt('elapsed_seconds') ?? 0;

    if (savedStartTime != null) {
      _startTime = DateTime.parse(savedStartTime);
      final now = DateTime.now();
      final difference = now.difference(_startTime!);

      setState(() {
        _seconds = savedSeconds + difference.inSeconds;
        _isRunning = true;
        _isShiftStarted = true;
      });

      _startTimer();
    }
  }

  Future<void> _saveShiftState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isRunning && _startTime != null) {
      await prefs.setString('start_time', _startTime!.toIso8601String());
      await prefs.setInt('elapsed_seconds', _seconds);
    } else {
      await prefs.remove('start_time');
      await prefs.remove('elapsed_seconds');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startStopwatch() {
    if (!_isRunning) {
      setState(() {
        _startTime = DateTime.now();
        _isRunning = true;
        _isShiftStarted = true;
      });
      _startTimer();
      _saveShiftState();
    }
  }

  void _startTimer() {
    _controller.forward();
    _timer.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
      _saveShiftState();
    });
  }

  Future<void> _resetStopwatch() async {
  if (_isRunning) {
    _timer.cancel();
    DateTime endTime = DateTime.now();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found.');
      }

      CollectionReference shiftCollection = FirebaseFirestore.instance
          .collection('Employees')
          .doc(user.uid) // Correctly using user.uid for authenticated user
          .collection('work_shifts');

      await shiftCollection.add({
        'start': _startTime!.toIso8601String(),
        'end': endTime.toIso8601String(),
        'date': _startTime!.toIso8601String().split('T')[0],
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift saved successfully.')),
      );

      // Refresh TimesheetPage if it exists in the widget tree
      TimesheetPageState? timesheetState =
          // ignore: use_build_context_synchronously
          context.findAncestorStateOfType<TimesheetPageState>();
      if (timesheetState != null) {
        await timesheetState.fetchShiftRecords();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save shift: ${e.toString()}')),
      );
    }
  }

  setState(() {
    _seconds = 0;
    _isRunning = false;
    _isShiftStarted = false;
    _startTime = null;
  });
  _controller.reverse();
  _saveShiftState();
}

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  List<Widget> _buildClockMarkers(double radius, double screenWidth) {
    List<Widget> markers = [];
    double rectangleWidth = screenWidth * 0.015;
    double rectangleHeight = screenWidth * 0.075;
    Color lighterDarkGrey = const Color.fromARGB(255, 85, 85, 85);

    for (int i = 0; i < 12; i++) {
      double angle = (i * 30.0) * (pi / 180);

      markers.add(
        Transform(
          transform: Matrix4.identity()
            ..translate(radius * cos(angle), radius * sin(angle))
            ..rotateZ(angle + pi / 2),
          alignment: Alignment.center,
          child: Container(
            width: rectangleWidth,
            height: rectangleHeight,
            decoration: BoxDecoration(
              color: _isShiftStarted ? Colors.green : lighterDarkGrey,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    double outerCircleDiameter = screenWidth * 0.75;
    double innerCircleDiameter = screenWidth * 0.85;
    double radius = outerCircleDiameter / 2.0 * 0.8;
    double timeFontSize = screenWidth * 0.10;
    double labelFontSize = screenWidth * 0.05;

    Color lighterDarkGrey = const Color.fromARGB(255, 85, 85, 85);
    Color darkGrey = const Color.fromARGB(255, 55, 55, 55);

    return Center(
      child: GestureDetector(
        onTap: _isShiftStarted ? _resetStopwatch : _startStopwatch,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double rotationValue = _controller.value * pi;
            bool isFlipped = _controller.value > 0.5;

            return Transform(
              transform: Matrix4.rotationY(rotationValue),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: innerCircleDiameter,
                    height: innerCircleDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: darkGrey.withOpacity(0.9),
                    ),
                  ),
                  Container(
                    width: outerCircleDiameter,
                    height: outerCircleDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isShiftStarted ? Colors.green : lighterDarkGrey,
                        width: screenWidth * 0.025,
                      ),
                    ),
                  ),
                  ..._buildClockMarkers(radius, screenWidth),
                  Transform(
                    transform: Matrix4.rotationY(isFlipped ? pi : 0),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_seconds),
                          style: GoogleFonts.exo2(
                            textStyle: TextStyle(
                              fontSize: timeFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          _isShiftStarted ? 'End Shift' : 'Start Shift',
                          style: GoogleFonts.exo2(
                            textStyle: TextStyle(
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  _isShiftStarted ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
