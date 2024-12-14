import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryManagementPage extends StatefulWidget {
  final Map<String, dynamic>? managerDetails; // Optional manager details

  const DeliveryManagementPage({super.key, this.managerDetails});

  @override
  _DeliveryManagementPageState createState() => _DeliveryManagementPageState();
}

class _DeliveryManagementPageState extends State<DeliveryManagementPage> {
  List<Map<String, dynamic>> deliveries = [
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
  late GoogleMapController mapController;

  void _updateStatus(int index, String newStatus) {
    if (index < 0 || index >= deliveries.length) {
      return;
    }
    if (newStatus.isEmpty) {
      return;
    }

    setState(() {
      deliveries = List.from(deliveries)
        ..[index] = {...deliveries[index], 'status': newStatus};
    });
  }

  Set<Marker> _buildMarkers() {
    return deliveries.map((delivery) {
      return Marker(
        markerId: MarkerId(delivery['id']),
        position: LatLng(delivery['latitude'], delivery['longitude']),
        infoWindow: InfoWindow(
          title: 'Delivery ${delivery['id']}',
          snippet: 'Assigned to: ${delivery['assignedTo']}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerHue(delivery['status']),
        ),
      );
    }).toSet();
  }

  double _getMarkerHue(String status) {
    switch (status) {
      case 'Active':
        return BitmapDescriptor.hueBlue;
      case 'Pending':
        return BitmapDescriptor.hueOrange;
      case 'Completed':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 60.0),

            // Search Field
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

            // Google Map with markers
            Container(
              height: 250,
              margin: const EdgeInsets.only(bottom: 15.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(35.2271, -80.8431),
                    zoom: 7.0,
                  ),
                  markers: _buildMarkers(),
                ),
              ),
            ),

            // Delivery List
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
                      subtitle: Text('Assigned to: ${delivery['assignedTo']}'),
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
    );
  }
}
