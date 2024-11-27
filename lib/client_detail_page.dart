import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as googleMaps;
//import 'package:latlong2/latlong.dart' as latLong;

class ClientDetailPage extends StatefulWidget {
  final Client client;

  const ClientDetailPage({super.key, required this.client});

  @override
  _ClientDetailPageState createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  late googleMaps.GoogleMapController
      _mapController; // Prefix for Google Maps Controller
  googleMaps.LatLng? _driverLocation; // Prefix for LatLng from Google Maps

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
      _driverLocation =
          googleMaps.LatLng(locationData.latitude!, locationData.longitude!);
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
                : googleMaps.GoogleMap(
                    initialCameraPosition: googleMaps.CameraPosition(
                      target: googleMaps.LatLng(
                        widget.client.location.latitude,
                        widget.client.location.longitude,
                      ),
                      zoom: 15,
                    ),
                    markers: {
                      googleMaps.Marker(
                        markerId: googleMaps.MarkerId("clientLocation"),
                        position: googleMaps.LatLng(
                          widget.client.location.latitude,
                          widget.client.location.longitude,
                        ),
                        infoWindow: googleMaps.InfoWindow(
                          title: widget.client.fullName,
                          snippet: widget.client.address,
                        ),
                      ),
                      googleMaps.Marker(
                        markerId: googleMaps.MarkerId("driverLocation"),
                        position: _driverLocation!,
                        infoWindow: const googleMaps.InfoWindow(
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

  void _startNavigation(googleMaps.LatLng destination) {
    // Add navigation functionality with Google Maps API or a third-party service
  }
}
