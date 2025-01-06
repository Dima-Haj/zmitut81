import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class EmployeeLocationPage extends StatelessWidget {
  // Function to get the current location of the employee
  Future<LatLng> getEmployeeLocation() async {
    Location location = Location();

    // Check if location services are enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return LatLng(32.849758840523386,
            35.17350796263602); // Default location (company)
      }
    }

    // Check if location permission is granted
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return LatLng(32.849758840523386,
            35.17350796263602); // Default location (company)
      }
    }

    // Get the current location
    LocationData locationData = await location.getLocation();
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  // Function to calculate the distance from two LatLng coordinates
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in km
    double dLat =
        (lat2 - lat1) * (3.141592653589793 / 180); // Convert degrees to radians
    double dLng =
        (lng2 - lng1) * (3.141592653589793 / 180); // Convert degrees to radians

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * (3.141592653589793 / 180)) *
            cos(lat2 * (3.141592653589793 / 180)) *
            (sin(dLng / 2) * sin(dLng / 2));

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c; // Distance in km
    return distance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employee Location')),
      body: Center(child: Text('Employee location page content goes here')),
    );
  }
}
