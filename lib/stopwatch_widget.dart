import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math'; // For sin, cos, and pi
import 'package:google_fonts/google_fonts.dart'; // Google fonts package

class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({super.key});

  @override
  _StopwatchWidgetState createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isShiftStarted = false; // To track if the shift has started
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Animation duration for the flip
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Start the stopwatch and trigger the flip animation
  void _startStopwatch() {
    if (!_isRunning) {
      _controller.forward().then((_) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _seconds++;
          });
        });
        setState(() {
          _isRunning = true;
          _isShiftStarted = true; // Mark that the shift has started
        });
      });
    }
  }

  // Reset the stopwatch and shift status
  void _resetStopwatch() {
    if (_isRunning) {
      _timer.cancel();
    }
    _controller.reverse().then((_) {
      setState(() {
        _seconds = 0;
        _isRunning = false;
        _isShiftStarted = false; // Reset shift status
      });
    });
  }

  // Time formatter
  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Generate rotated and positioned rectangles around the circle
  List<Widget> _buildClockMarkers(double radius, double screenWidth) {
    List<Widget> markers = [];
    double rectangleWidth =
        screenWidth * 0.015; // Rectangle width as 2.2% of screen width
    double rectangleHeight =
        screenWidth * 0.075; // Rectangle height as 7% of screen width
    Color lighterDarkGrey = const Color.fromARGB(
        255, 85, 85, 85); // Lighter dark grey for the rectangles

    for (int i = 0; i < 12; i++) {
      double angle = (i * 30.0) *
          (pi /
              180); // Convert degrees to radians (30 degrees for each hour marker)

      markers.add(
        Transform(
          transform: Matrix4.identity()
            ..translate(
                radius * cos(angle), radius * sin(angle)) // Adjust position
            ..rotateZ(
                angle + pi / 2), // Rotate to align with the circle's radius
          alignment: Alignment.center,
          child: Container(
            width: rectangleWidth, // Small width for the rectangles
            height: rectangleHeight, // Height of the rectangles
            decoration: BoxDecoration(
              color: _isShiftStarted
                  ? Colors.green
                  : lighterDarkGrey, // Initially lighter dark grey, green after shift starts
              borderRadius:
                  BorderRadius.circular(4.0), // Rounded corners for rectangles
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    // Circle sizes and radius based on screen size
    double outerCircleDiameter = screenWidth * 0.75; // 75% of screen width
    double innerCircleDiameter = screenWidth * 0.85; // Inner glowing circle
    double radius =
        outerCircleDiameter / 2.0 * 0.8; // Adjust the radius for clock markers

    // Adjust font sizes based on screen size
    double timeFontSize = screenWidth * 0.10; // 12% of screen width
    double labelFontSize = screenWidth * 0.05; // 5% of screen width

    // Colors for the elements
    Color lighterDarkGrey = const Color.fromARGB(
        255, 85, 85, 85); // Lighter dark grey for the rectangles
    Color evenLighterGrey = const Color.fromARGB(
        255, 120, 120, 120); // Lighter grey for the inner circle background
    Color darkGrey =
        const Color.fromARGB(255, 55, 55, 55); // Dark grey for the outer border

    return Center(
      child: GestureDetector(
        onTap: _isShiftStarted
            ? _resetStopwatch
            : _startStopwatch, // Start/Reset on tap
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // 3D flip effect on the Y-axis
            double rotationValue =
                _controller.value * pi; // Rotation in radians
            bool isFlipped =
                _controller.value > 0.5; // Flip complete after halfway

            return Transform(
              transform: Matrix4.rotationY(rotationValue),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Circle (lighter grey)
                  Container(
                    width: innerCircleDiameter,
                    height: innerCircleDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          darkGrey.withOpacity(0.8), // Lighter grey background
                    ),
                  ),

                  // Outer Circle Timer (Clickable, changes to green if shift started)
                  Container(
                    width: outerCircleDiameter,
                    height: outerCircleDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isShiftStarted
                            ? Colors.green
                            : lighterDarkGrey, // Turn green after shift starts
                        width: screenWidth *
                            0.015, // 2.5% of screen width for border width
                      ),
                    ),
                  ),

                  // Add Clock Markers (lighter dark grey, turns green after shift starts)
                  ..._buildClockMarkers(radius, screenWidth),

                  // Inner time display
                  Transform(
                    // Counter rotate the inner content to keep it upright
                    transform: Matrix4.rotationY(isFlipped ? pi : 0),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_seconds),
                          style: GoogleFonts.exo2(
                            textStyle: TextStyle(
                              fontSize: timeFontSize, // Scaled font size

                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: screenHeight *
                                0.02), // Space based on screen height
                        Text(
                          _isShiftStarted
                              ? 'End Shift'
                              : 'Start Shift', // Change text based on shift state
                          style: GoogleFonts.exo2(
                            textStyle: TextStyle(
                              fontSize:
                                  labelFontSize, // Scaled font size for label
                              fontWeight: FontWeight.bold,
                              color: _isShiftStarted
                                  ? Colors.red
                                  : Colors
                                      .green, // Start Shift in green, End Shift in red
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
