import 'package:flutter/material.dart';

class TimesheetPage extends StatelessWidget {
  final Map<DateTime, int> shiftRecords;

  const TimesheetPage({super.key, required this.shiftRecords});

  // Helper method to format the duration in hours and minutes
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

        // Foreground content (shift records)
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
              
              // Display shift records
              Expanded(
                child: ListView.builder(
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
