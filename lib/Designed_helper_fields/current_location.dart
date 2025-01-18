import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmployeeLocationPage extends StatelessWidget {
  const EmployeeLocationPage({super.key});

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

  Future<double> calculateDistanceFromGoogleMaps(
      LatLng origin, LatLng destination) async {
    final apiKey =
        'AIzaSyAGJkXj13xt1A665k3XO5GspS6i6tbieuA'; // Replace with your Google Maps API key
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&key=$apiKey',
    );

    try {
      // Make the API call
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          // Get the distance (in meters) from the first route's legs
          final legs = data['routes'][0]['legs'];
          final distanceInMeters = legs[0]['distance']['value'];

          // Convert distance to kilometers
          final distanceInKm = distanceInMeters / 1000.0;
          return distanceInKm;
        } else {
          throw Exception('No routes found');
        }
      } else {
        throw Exception('Failed to load directions');
      }
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employee Location')),
      body: Center(child: Text('Employee location page content goes here')),
    );
  }
}
