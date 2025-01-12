import 'package:cloud_firestore/cloud_firestore.dart';
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
  Map<DateTime, List<String>> _eventMap =
      {}; // To store the deliveries per date

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchDeliveries(); // Fetch deliveries when the page is loaded
  }

  void _fetchDeliveries() async {
    try {
      // Fetch all employees from the "Employees" collection
      QuerySnapshot employeesSnapshot = await FirebaseFirestore.instance
          .collection('Employees') // The root collection for all employees
          .get();

      Map<DateTime, List<String>> tempEventMap = {};

      for (var employeeDoc in employeesSnapshot.docs) {
        // For each employee, fetch their "dailyDeliveries" sub-collection
        QuerySnapshot deliveriesSnapshot = await FirebaseFirestore.instance
            .collection('Employees')
            .doc(employeeDoc.id) // Employee document ID
            .collection(
                'dailyDeliveries') // Sub-collection containing deliveries
            .get();

        // Iterate through all the fetched deliveries
        for (var doc in deliveriesSnapshot.docs) {
          var deliveryData = doc.data() as Map<String, dynamic>;

          // Get the delivery date and handle both String and Timestamp cases
          var deliveryDateField = deliveryData['date'];

          DateTime deliveryDate;
          if (deliveryDateField is Timestamp) {
            // Handle Timestamp (Firestore default)
            deliveryDate = deliveryDateField.toDate();
          } else if (deliveryDateField is String) {
            // Handle String (if it's a string date)
            deliveryDate = DateTime.parse(deliveryDateField);
          } else {
            continue; // Skip if the date is not valid
          }

          // Normalize the date (to remove time)
          DateTime normalizedDate =
              DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day);

          // Get the name and address fields
          String name = deliveryData['name'] ?? 'Unknown Name';
          String clientAddress =
              deliveryData['clientAddress'] ?? 'Unknown Address';

          // Combine the name and address into a delivery detail string
          String deliveryDetails = "$name - $clientAddress";

          // Add delivery details to the event map
          if (tempEventMap.containsKey(normalizedDate)) {
            tempEventMap[normalizedDate]!.add(deliveryDetails);
          } else {
            tempEventMap[normalizedDate] = [deliveryDetails];
          }
        }
      }

      // Update the state with the event map
      setState(() {
        _eventMap = tempEventMap;
      });
    } catch (e) {
      print('Error fetching deliveries: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get all the dates that have deliveries
    Map<DateTime, List<String>> eventMap = widget.eventMap;
    Set<DateTime> eventDates = eventMap.keys.toSet();

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
              weekendTextStyle: const TextStyle(color: Colors.red),
              defaultTextStyle: const TextStyle(fontSize: 16),
            ),
            eventLoader: (day) {
              // Normalize the selected date to remove time for accurate matching
              DateTime normalizedDate = DateTime(day.year, day.month, day.day);
              return _eventMap[normalizedDate] ?? [];
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.4,
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
                    // Check if deliveries are available for the selected date
                    if (_eventMap.containsKey(_selectedDay) &&
                        _eventMap[_selectedDay]!.isNotEmpty)
                      ..._eventMap[_selectedDay]!.map((event) {
                        // Assuming the event is a string like "Product - Client Address"
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                              event), // event should display name and address
                        );
                      }).toList()
                    else
                      const Text(
                          "אין משלוחים ליום זה"), // "No deliveries for this day"
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
