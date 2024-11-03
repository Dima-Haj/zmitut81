import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'client.dart';

class ClientDetailPage extends StatefulWidget {
  final Client client;

  const ClientDetailPage({super.key, required this.client});

  @override
  _ClientDetailPageState createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  late GoogleMapController _mapController;
  LatLng? _driverLocation;

  @override
  void initState() {
    super.initState();
    _getDriverLocation();
  }

  Future<void> _getDriverLocation() async {
    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locationData = await location.getLocation();
    setState(() {
      _driverLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.client.fullName)),
      body: Column(
        children: [
          ListTile(
            title: Text(widget.client.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phone: ${widget.client.phoneNumber}"),
                Text("Email: ${widget.client.email}"),
                Text("Address: ${widget.client.address}"),
              ],
            ),
          ),
          Expanded(
            child: _driverLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.client.location,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId("clientLocation"),
                        position: widget.client.location,
                        infoWindow: InfoWindow(
                          title: widget.client.fullName,
                          snippet: widget.client.address,
                        ),
                      ),
                      Marker(
                        markerId: MarkerId("driverLocation"),
                        position: _driverLocation!,
                        infoWindow: const InfoWindow(
                          title: "Your Location",
                        ),
                      ),
                    },
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Trigger navigation
                _startNavigation(widget.client.location);
              },
              child: const Text('Start Driving'),
            ),
          ),
        ],
      ),
    );
  }

  void _startNavigation(LatLng destination) {
    // Add navigation functionality with Google Maps API or a third-party service
  }
}
