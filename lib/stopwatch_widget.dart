import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StopwatchWidget extends StatefulWidget {
  final Function(DateTime, int) onShiftEnd;

  const StopwatchWidget({super.key, required this.onShiftEnd});

  @override
  StopwatchWidgetState createState() => StopwatchWidgetState();
}

class StopwatchWidgetState extends State<StopwatchWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isShiftStarted = false;
  DateTime? _startTime; // To keep track of the start time
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _loadShiftState(); // Load state on startup
  }

  // Load state on startup to check if shift was active and continue counting if needed
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
      
      _startTimer(); // Resume timer
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

  // Start the stopwatch and save the start time
  void _startStopwatch() {
    if (!_isRunning) {
      setState(() {
        _startTime = DateTime.now(); // Set the start time
        _isRunning = true;
        _isShiftStarted = true;
      });
      _startTimer();
      _saveShiftState();
    }
  }

  void _startTimer() {
    _controller.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
      _saveShiftState();
    });
  }

  // Reset the stopwatch and shift status
  void _resetStopwatch() {
    if (_isRunning) {
      _timer.cancel();
      DateTime endTime = DateTime.now();
      widget.onShiftEnd(endTime, _seconds); // Save the shift end time and duration
    }
    setState(() {
      _seconds = 0;
      _isRunning = false;
      _isShiftStarted = false;
      _startTime = null; // Clear start time
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
                              color: _isShiftStarted ? Colors.red : Colors.green,
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