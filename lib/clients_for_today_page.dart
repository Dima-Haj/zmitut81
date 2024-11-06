import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'client.dart';

class ClientsForTodayPage extends StatefulWidget {
  const ClientsForTodayPage({super.key});

  @override
  _ClientsForTodayPageState createState() => _ClientsForTodayPageState();
}

class _ClientsForTodayPageState extends State<ClientsForTodayPage> {
  final List<Client> clients = [
    Client(
      fullName: 'John Doe',
      phoneNumber: '123-456-7890',
      email: 'johndoe@example.com',
      address: '123 Main St, Cityville',
      location: LatLng(37.4219999, -122.0840575),
    ),
    Client(
      fullName: 'Jane Smith',
      phoneNumber: '098-765-4321',
      email: 'janesmith@example.com',
      address: '456 Park Ave, Townsville',
      location: LatLng(37.4235, -122.0817),
    ),
    // Add more clients as needed
  ];

  final Map<int, bool> _expandedClientMap = {}; // Track expanded state of each client
  final Map<int, String> _estimatedTimes =
      {}; // Store estimated times for each client

  @override
  void initState() {
    super.initState();
    _fetchEstimatedTimes();
  }

  Future<void> _fetchEstimatedTimes() async {
    final location = Location();
    final userLocation = await location.getLocation();

    for (int i = 0; i < clients.length; i++) {
      final client = clients[i];
      final duration = await _getTravelTimeWithTraffic(
        LatLng(userLocation.latitude!, userLocation.longitude!),
        client.location,
      );
      setState(() {
        _estimatedTimes[i] = duration;
      });
    }
  }

  Future<String> _getTravelTimeWithTraffic(
      LatLng origin, LatLng destination) async {
    final apiKey =
        'YOUR_GOOGLE_MAPS_API_KEY'; // Replace with your Google Maps API key
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=driving&departure_time=now&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final duration =
          data['routes'][0]['legs'][0]['duration_in_traffic']['text'];
      return duration;
    } else {
      throw Exception('Failed to load travel time');
    }
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
            top: screenHeight * 0.03,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo_zmitut.png',
                height: screenHeight * 0.06,
                fit: BoxFit.contain,
              ),
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
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: client.location,
                                    zoom: 14,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: MarkerId(client.fullName),
                                      position: client.location,
                                      infoWindow: InfoWindow(
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

  void _startNavigation(LatLng destination) async {
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
