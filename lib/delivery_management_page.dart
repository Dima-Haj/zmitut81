import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

class DeliveryManagementPage extends StatefulWidget {
  const DeliveryManagementPage({Key? key}) : super(key: key);

  @override
  State<DeliveryManagementPage> createState() => _DeliveryManagementPageState();
}

class _DeliveryManagementPageState extends State<DeliveryManagementPage> {
  final List<Map<String, dynamic>> deliveries = [
    {
      'id': 'D001',
      'status': 'Active',
      'assignedTo': 'Driver 1',
      'latitude': 35.2271,
      'longitude': -80.8431,
    },
    {
      'id': 'D002',
      'status': 'Pending',
      'assignedTo': 'Driver 2',
      'latitude': 36.0726,
      'longitude': -79.7910,
    },
    {
      'id': 'D003',
      'status': 'Completed',
      'assignedTo': 'Driver 3',
      'latitude': 35.9940,
      'longitude': -78.8986,
    },
  ];

  final List<String> validStatuses = ['Pending', 'Active', 'Completed'];

  void _updateStatus(int index, String newStatus) {
    setState(() {
      deliveries[index]['status'] = newStatus;
    });
  }

  Color _getMarkerColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/image1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color.fromARGB(255, 42, 42, 42).withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 60.0),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    hintText: 'Search Deliveries...',
                    hintStyle: GoogleFonts.exo2(
                      fontSize: 16.0,
                      color: const Color.fromARGB(255, 105, 105, 105),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.exo2(color: Colors.black),
                ),
                const SizedBox(height: 15.0),
                // Map with manual markers
                Container(
                  height: 250,
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: latlng.LatLng(35.2271, -80.8431),
                          initialZoom: 7.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                          ),
                        ],
                      ),
                      // Custom marker overlay
                      ...deliveries.map((delivery) {
                        final color = _getMarkerColor(delivery['status']);
                        return Positioned(
                          left: 100.0, // Calculate appropriate position here
                          top: 100.0, // Calculate appropriate position here
                          child: Icon(
                            Icons.location_on,
                            color: color,
                            size: 30.0,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: deliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = deliveries[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            items: validStatuses
                                .map<DropdownMenuItem<String>>((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
