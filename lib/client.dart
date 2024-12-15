// client.dart

import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;

class Client {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String address;
  final google_maps.LatLng location; // Prefix LatLng with googleMaps

  Client({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.location,
  });
}
