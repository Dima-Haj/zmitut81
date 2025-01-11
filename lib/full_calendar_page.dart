import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class FullCalendarPage extends StatefulWidget {
  final Map<DateTime, List<String>> eventMap;

  const FullCalendarPage({super.key, required this.eventMap});

  @override
  _FullCalendarPageState createState() => _FullCalendarPageState();
}

class _FullCalendarPageState extends State<FullCalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("לוח שנה"), // "Calendar" in Hebrew
        backgroundColor: const Color.fromARGB(255, 141, 126, 106),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'he_IL',
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: const Icon(Icons.chevron_right), // RTL support
              rightChevronIcon: const Icon(Icons.chevron_left),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
              defaultTextStyle: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          // Display deliveries for the selected day below the calendar
          Expanded(
            child: Center(
              // Center the container if desired
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // Set width to 90% of the screen width
                height: MediaQuery.of(context).size.height *
                    0.4, // Set height to 40% of the screen height
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "משלוחים ל ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...widget.eventMap[_selectedDay]?.map(
                          (event) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text("- $event"),
                          ),
                        ) ??
                        [
                          const Text("אין משלוחים ליום זה")
                        ], // "No deliveries for this day" in Hebrew
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
