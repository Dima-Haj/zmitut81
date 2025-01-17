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
  Map<DateTime, List<String>> _eventMap = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _eventMap = {...widget.eventMap}; // Initialize with passed data
    _fetchAllData(); // Unified data fetching
  }

  void _fetchAllData() async {
    try {
      await Future.wait([
        _fetchDeliveries(),
        _fetchCategorizedOrders(),
      ]);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _fetchDeliveries() async {
    try {
      QuerySnapshot employeesSnapshot =
          await FirebaseFirestore.instance.collection('Employees').get();

      Map<DateTime, List<String>> tempEventMap = {..._eventMap};

      for (var employeeDoc in employeesSnapshot.docs) {
        QuerySnapshot deliveriesSnapshot = await FirebaseFirestore.instance
            .collection('Employees')
            .doc(employeeDoc.id)
            .collection('dailyDeliveries')
            .get();

        for (var doc in deliveriesSnapshot.docs) {
          var deliveryData = doc.data() as Map<String, dynamic>;

          DateTime? deliveryDate = _parseDate(deliveryData['date']);
          if (deliveryDate == null) continue;

          String name = deliveryData['name'] ?? 'Unknown Name';
          String clientAddress =
              deliveryData['clientAddress'] ?? 'Unknown Address';
          String status = deliveryData['status'] ?? 'Unknown Status';

          String deliveryDetails = "$name - $clientAddress - $status";

          tempEventMap.update(
            deliveryDate,
            (existing) => [...existing, deliveryDetails],
            ifAbsent: () => [deliveryDetails],
          );
        }
      }

      QuerySnapshot clientsSnapshot =
          await FirebaseFirestore.instance.collection('clients').get();

      for (var clientDoc in clientsSnapshot.docs) {
        QuerySnapshot previousDeliveriesSnapshot = await FirebaseFirestore
            .instance
            .collection('clients')
            .doc(clientDoc.id)
            .collection('previousDeliveries')
            .get();

        for (var doc in previousDeliveriesSnapshot.docs) {
          var deliveryData = doc.data() as Map<String, dynamic>;

          DateTime? deliveryDate = _parseDate(deliveryData['deliveryDate']);
          if (deliveryDate == null) continue;

          String name = deliveryData['name'] ?? 'Unknown Name';
          String address = clientDoc['address'] ?? 'Unknown Address';
          String status = deliveryData['status'] ?? 'Unknown Status';

          String deliveryDetails = "$name - $address - $status";

          tempEventMap.update(
            deliveryDate,
            (existing) => [...existing, deliveryDetails],
            ifAbsent: () => [deliveryDetails],
          );
        }
      }

      setState(() {
        _eventMap = tempEventMap;
      });
    } catch (e) {
      print('Error fetching deliveries: $e');
    }
  }

  Future<void> _fetchCategorizedOrders() async {
    try {
      Map<DateTime, List<String>> tempEventMap = {..._eventMap};

      QuerySnapshot categorizedOrdersSnapshot = await FirebaseFirestore.instance
          .collection('categorizedOrders')
          .get();

      for (var categoryDoc in categorizedOrdersSnapshot.docs) {
        var categoryData = categoryDoc.data() as Map<String, dynamic>;

        for (String categoryKey in ['big', 'small']) {
          if (categoryData.containsKey(categoryKey)) {
            List<dynamic> orders = categoryData[categoryKey];

            for (var order in orders) {
              DateTime? deliveryDate = _parseDate(order['date']);
              if (deliveryDate == null) continue;

              String name = order['name'] ?? 'שם לא ידוע';
              String clientAddress = order['clientAddress'] ?? 'מיקום לא ידוע';
              String status = order['status'] ?? 'סטטוס לא ידוע';

              String deliveryDetails = "$name - $clientAddress - $status";

              tempEventMap.update(
                deliveryDate,
                (existing) => [...existing, deliveryDetails],
                ifAbsent: () => [deliveryDetails],
              );
            }
          }
        }
      }

      setState(() {
        _eventMap = tempEventMap;
      });
    } catch (e) {
      print('Error fetching categorized orders: $e');
    }
  }

  DateTime? _parseDate(dynamic dateField) {
    if (dateField is Timestamp) {
      return dateField.toDate();
    } else if (dateField is String) {
      try {
        return DateTime.parse(dateField);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("לוח שנה"), // "Calendar" in Hebrew
        backgroundColor: const Color.fromARGB(255, 141, 126, 106),
      ),
      body: Container(
        color: Colors.white, // Add white background
        child: Column(
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
                  _selectedDay = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  );
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
                leftChevronIcon: const Icon(Icons.chevron_right),
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
                DateTime normalizedDate =
                    DateTime(day.year, day.month, day.day);
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
                      if (_eventMap.containsKey(_selectedDay) &&
                          _eventMap[_selectedDay]!.isNotEmpty)
                        ..._eventMap[_selectedDay]!.map((event) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(event),
                            ))
                      else
                        const Text("אין משלוחים ליום זה"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
