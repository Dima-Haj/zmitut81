import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryManagementPage extends StatefulWidget {
  final Map<String, dynamic>? managerDetails; // Optional manager details

  const DeliveryManagementPage({super.key, this.managerDetails});

  @override
  State<DeliveryManagementPage> createState() => _DeliveryManagementPageState();
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
        markerId: MarkerId(delivery['id']), // Required parameter
        position: LatLng(
            delivery['latitude'], delivery['longitude']), // Correct position
        infoWindow: InfoWindow(
          title: 'Delivery ${delivery['id']}',
          snippet: 'Assigned to: ${delivery['assignedTo']}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerHue(delivery['status']), // Status-based marker hue
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

  Color _getStatusColor(String status) {
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
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(35.2271, -80.8431), // Initial center
                      zoom: 7.0, // Zoom level
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      if (mounted) {
                        setState(() {
                          mapController = controller;
                        });
                      }
                    },
                    markers: _buildMarkers(), // Add markers to the map
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
                          trailing: Container(
                            width: 110,
                            height: 33,
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(delivery[
                                  'status']), // Dynamic color based on status
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              delivery['status'],
                              style: GoogleFonts.exo2(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
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
