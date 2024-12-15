import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'api_key_provider.dart';
import 'login_page.dart'; // Import the utility file

class ClientsForTodayPage extends StatefulWidget {
  const ClientsForTodayPage({super.key});

  @override
  _ClientsForTodayPageState createState() => _ClientsForTodayPageState();
}

class _ClientsForTodayPageState extends State<ClientsForTodayPage> {
  String userLocationMessage = "Fetching your location...";
  final List<Client> clients = [
    Client(
      fullName: 'Haifa Client',
      phoneNumber: '123-456-7890',
      email: 'haifa@example.com',
      address: 'HaNamal St 23, Haifa, Israel', // Example address
      location: google_maps.LatLng(
          32.819121, 34.995682), // Coordinates for HaNamal Street
    ),
    Client(
      fullName: 'Jane Smith',
      phoneNumber: '098-765-4321',
      email: 'janesmith@example.com',
      address: '456 Park Ave, Townsville',
      location: google_maps.LatLng(37.4219999, -122.0840575),
    ),
    // Add more clients as needed
  ];

  final Map<int, bool> _expandedClientMap =
      {}; // Track expanded state of each client
  final Map<int, String> _estimatedTimes =
      {}; // Store estimated times for each client

  @override
  void initState() {
    super.initState();
    _fetchEstimatedTimes();
  }

  Future<void> _fetchEstimatedTimes() async {
    final location = Location();

    // Check and request location permissions
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (mounted) {
          setState(() {
            userLocationMessage =
                "Location permission denied. Can't fetch estimated times.";
          });
        }
        return;
      }
    }

    try {
      // Get user's current location
      final userLocation = await location.getLocation();
      // Fetch travel times concurrently for all clients
      final futures = clients.asMap().entries.map((entry) async {
        final index = entry.key;
        final client = entry.value;

        try {
          final duration = await _getTravelTimeWithTraffic(
            google_maps.LatLng(userLocation.latitude!, userLocation.longitude!),
            client.location,
          );

          // Update estimated time for this client
          if (mounted) {
            setState(() {
              _estimatedTimes[index] = duration;
            });
          }
        } catch (e) {
          // Handle errors for individual client calculations
          if (mounted) {
            setState(() {
              _estimatedTimes[index] = "Error fetching ETA";
            });
          }
        }
      }).toList();

      // Wait for all futures to complete
      await Future.wait(futures);
    } catch (e) {
      // Handle general location fetching errors
      if (mounted) {
        setState(() {
          userLocationMessage =
              "Failed to fetch user location: ${e.toString()}";
        });
      }
    }
  }

  Future<String> _getTravelTimeWithTraffic(
      google_maps.LatLng origin, google_maps.LatLng destination) async {
    final apiKey = await ApiKeyProvider
        .getApiKey(); // Ensure this uses your platform-specific API key

    if (!_isValidLatLng(origin) || !_isValidLatLng(destination)) {
      return 'Invalid origin or destination.';
    }
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=driving&departure_time=now&key=$apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] == null || data['routes'].isEmpty) {
          return 'No routes found.';
        }

        final duration =
            data['routes'][0]['legs'][0]['duration_in_traffic']['text'];
        return duration;
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }

  bool _isValidLatLng(google_maps.LatLng latLng) {
    // Latitude ranges from -90 to 90, and longitude ranges from -180 to 180.
    return latLng.latitude >= -90 &&
        latLng.latitude <= 90 &&
        latLng.longitude >= -180 &&
        latLng.longitude <= 180;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            height: screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/image1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.7),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Logo at the top
          Positioned(
            top: screenHeight * 0.07,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159), // Rotate 180 degrees
                    child: const Icon(Icons.logout, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_zmitut.png',
                      height: screenHeight * 0.06,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.1), // Placeholder for spacing
              ],
            ),
          ),
          // List of clients with expandable maps
          Positioned.fill(
            top: screenHeight * 0.1, // Adjust top padding for logo
            child: ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                final isExpanded = _expandedClientMap[index] ?? false;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedClientMap[index] = !isExpanded;
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.04,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.fullName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  client.address,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: screenHeight * 0.02,
                                  ),
                                ),
                                if (_estimatedTimes.containsKey(index))
                                  Text(
                                    'ETA: ${_estimatedTimes[index]}',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: screenHeight * 0.02,
                                    ),
                                  ),
                              ],
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.white,
                              size: screenHeight * 0.03,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: Column(
                          children: [
                            Container(
                              height: screenHeight * 0.25,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(screenHeight * 0.015),
                                border:
                                    Border.all(color: Colors.white70, width: 1),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(screenHeight * 0.015),
                                child: google_maps.GoogleMap(
                                  initialCameraPosition:
                                      google_maps.CameraPosition(
                                    target: client
                                        .location, // Ensure client.location is googleMaps.LatLng
                                    zoom: 14,
                                  ),
                                  markers: {
                                    google_maps.Marker(
                                      markerId:
                                          google_maps.MarkerId(client.fullName),
                                      position: client
                                          .location, // Ensure this is googleMaps.LatLng
                                      infoWindow: google_maps.InfoWindow(
                                        title: client.fullName,
                                        snippet: client.address,
                                      ),
                                    ),
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01,
                                      horizontal: screenWidth * 0.04,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          screenHeight * 0.015),
                                    ),
                                    backgroundColor: Colors.orangeAccent,
                                  ),
                                  icon: Icon(Icons.directions,
                                      size: screenHeight * 0.025),
                                  label: Text(
                                    'Start Delivery',
                                    style: TextStyle(
                                        fontSize: screenHeight * 0.022),
                                  ),
                                  onPressed: () {
                                    _startNavigation(client.location);
                                  },
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01,
                                      horizontal: screenWidth * 0.05,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          screenHeight * 0.015),
                                    ),
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                  icon: Icon(Icons.phone,
                                      size: screenHeight * 0.025),
                                  label: Text(
                                    'Contact',
                                    style: TextStyle(
                                        fontSize: screenHeight * 0.022),
                                  ),
                                  onPressed: () {
                                    _contactClient(client.phoneNumber);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startNavigation(google_maps.LatLng destination) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}&travelmode=driving',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  void _contactClient(String phoneNumber) async {
    final Uri phoneUrl = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }
}
