import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryManagementPage extends StatefulWidget {
  const DeliveryManagementPage({super.key});

  @override
  _DeliveryManagementPageState createState() => _DeliveryManagementPageState();
}

class _DeliveryManagementPageState extends State<DeliveryManagementPage> {
  final List<Map<String, dynamic>> deliveries = [
    {
      'id': 'D001',
      'status': 'Active',
      'assignedTo': 'Driver 1',
      'location': '35.2271,-80.8431',
    },
    {
      'id': 'D002',
      'status': 'Pending',
      'assignedTo': 'Driver 2',
      'location': '36.0726,-79.7910',
    },
    {
      'id': 'D003',
      'status': 'Completed',
      'assignedTo': 'Driver 3',
      'location': '35.9940,-78.8986',
    },
  ];

  // List of valid statuses
  final List<String> validStatuses = ['Pending', 'Active', 'Completed'];

  // Update the status of a delivery
  void _updateStatus(int index, String newStatus) {
    setState(() {
      deliveries[index]['status'] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
                'assets/images/image1.png'), // Background image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.65),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 60.0), // Adds space above search field

              // Search field
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white
                      .withOpacity(0.8), // Search field background color
                  hintText: 'Search Deliveries...',
                  hintStyle: GoogleFonts.exo2(
                    fontSize: 16.0,
                    color: const Color.fromARGB(
                        255, 105, 105, 105), // Set hint text color
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style:
                    GoogleFonts.exo2(color: Colors.black), // Search text color
              ),

              const SizedBox(height: 15.0), // Adds space below the search field

              // Delivery list
              Expanded(
                child: ListView.builder(
                  itemCount: deliveries.length,
                  itemBuilder: (context, index) {
                    final delivery = deliveries[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // Box color
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          'Delivery ${delivery['id']}',
                          style: GoogleFonts.exo2(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text('Assigned to: ${delivery['assignedTo']}'),
                        trailing: DropdownButton<String>(
                          value: delivery['status'],
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: GoogleFonts.exo2(color: Colors.black87),
                          underline: Container(
                            height: 2,
                            color: Colors.black54,
                          ),
                          onChanged: (String? newStatus) {
                            if (newStatus != null) {
                              _updateStatus(index, newStatus);
                            }
                          },
                          items: validStatuses.map<DropdownMenuItem<String>>(
                            (String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
