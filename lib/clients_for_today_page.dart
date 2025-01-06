import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'login_page.dart'; // Import the utility file
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'currentLocation.dart';

class ClientsForTodayPage extends StatefulWidget {
  const ClientsForTodayPage({super.key});

  @override
  _ClientsForTodayPageState createState() => _ClientsForTodayPageState();
}

class _ClientsForTodayPageState extends State<ClientsForTodayPage> {
  String userLocationMessage = "Fetching your location...";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Client> clients = [];
  final String apiKey = 'AIzaSyBXHnIAKqan9xNW5XEgaPe1JBVgFAexIR8';
  List<Map<String, dynamic>> _clientTimes = []; // Initialize as an empty list
  DateTime? _returnTime; // To store a single return time
  final Map<String, double> companyLocation = {
    'latitude': 32.849758840523386,
    'longitude': 35.17350796263602,
  };
  bool isLoading = true; // To track loading state
  bool isRunning = false;
  bool isRunningOrder = false; // Track if the order preparation started
  bool isDeliveryStarted = false;

  Future<google_maps.LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      // URL encode the address
      final encodedAddress = Uri.encodeComponent(address);

      // Construct the Geocoding API request URL
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey";

      // Make the API request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check for a successful response
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final latitude = location['lat'];
          final longitude = location['lng'];

          // Return the LatLng object
          return google_maps.LatLng(latitude, longitude);
        } else {}
      } else {}
      // ignore: empty_catches
    } catch (e) {}

    // Return null if the operation fails
    return null;
  }

  Future<void> fetchClientsFromFirebase() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Reference to Firestore
      final firestore = FirebaseFirestore.instance;

      // Fetch the employee document by userId
      final employeeDoc = firestore.collection('Employees').doc(user.uid);

      // Fetch the `dailyDeliveries` subcollection
      final dailyDeliveriesSnapshot =
          await employeeDoc.collection('dailyDeliveries').get();

      if (dailyDeliveriesSnapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Iterate through the documents in the subcollection
      for (var doc in dailyDeliveriesSnapshot.docs) {
        final data = doc.data();

        if (data['clientName'] != null &&
            data['clientAddress'] != null &&
            data['clientPhone'] != null &&
            data['clientLat'] != null &&
            data['clientLng'] != null &&
            data['departureTime'] != null &&
            data['status'] != null &&
            data['orderId'] != null &&
            data['clientId'] != null) {
          // Convert address to LatLng (if possible)

          // Create Client object and add to the list
          final client = Client(
            fullName: data['clientName'],
            phoneNumber: data['clientPhone'],
            email: data['clientEmail'] ?? '',
            address: data['clientAddress'],
            lat: data['clientLat'],
            lng: data['clientLng'],
            status: data['status'],
            departureTime: data['departureTime'],
            orderId: data['orderId'],
            clientId: data['clientId'],
          );
          if (client.status == "בתהליך" || client.status == "בדרך ללקוח") {
            setState(() {
              isRunningOrder = true; // Set to true after clicking
            });
          }
          if (client.status == "בדרך ללקוח") {
            setState(() {
              isDeliveryStarted = true; // Set to true after clicking
            });
          }

          clients.add(client);
        }
      }
      clients.sort((a, b) {
        DateTime timeA = DateTime.parse(a.departureTime);
        DateTime timeB = DateTime.parse(b.departureTime);
        return timeA.compareTo(timeB); // Compare the DateTime objects
      });

      setState(() {
        isLoading = false; // Update loading state after fetching data
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false; // Ensure loading state is reset even on error
        });
      }
    }
  }

  final Map<int, bool> _expandedClientMap = {};
  final Map<int, String> _estimatedTimes = {};
  String convertToHebrew(String duration) {
    // Split the English duration string
    List<String> parts = duration.split(' ');

    // Create a map for translation
    Map<String, String> translationMap = {
      "hour": "שעה",
      "hours": "שעות",
      "min": "דקה",
      "mins": "דקות",
    };

    // Translate and rebuild the string in Hebrew
    String hebrewDuration = "";
    for (int i = 0; i < parts.length; i++) {
      if (translationMap.containsKey(parts[i])) {
        hebrewDuration += "${translationMap[parts[i]]} ";
      } else {
        hebrewDuration += "${parts[i]} "; // Add numbers or untranslatable parts
      }
    }

    return hebrewDuration.trim();
  }

  @override
  void initState() {
    super.initState();
    _initializeClients();
    _fetchShiftStateFromDatabase();
    _getEmployeeLocationAndCalculateDistance();
  }

  // Get employee location and calculate distance from company location
  Future<void> _getEmployeeLocationAndCalculateDistance() async {
    // Initialize EmployeeLocationPage
    EmployeeLocationPage locationPage = EmployeeLocationPage();

    // Get the current location of the employee
    LatLng currentLocation = await locationPage.getEmployeeLocation();

    // Calculate the distance from the company location
    double distance = locationPage.calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
      companyLocation['latitude']!,
      companyLocation['longitude']!,
    );

    // Show the result (you can use it in your app as needed)
    print('Distance from employee to company: $distance km');
  }

  Future<void> _fetchShiftStateFromDatabase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user found.');

      final employeeDocRef =
          FirebaseFirestore.instance.collection('Employees').doc(user.uid);

      final shiftDoc = await employeeDocRef
          .collection('activeShift')
          .doc('currentShift')
          .get();

      if (shiftDoc.exists) {
        final data = shiftDoc.data();
        if (data != null && data.containsKey('isRunning')) {
          if (mounted) {
            setState(() {
              isRunning = data['isRunning'] as bool;
            });
          }
        }
      } else {
        debugPrint('No active shift found for the user.');
      }
    } catch (e) {
      debugPrint('Error fetching shift state: $e');
    }
  }

  Future<void> _initializeClients() async {
    await fetchClientsFromFirebase();
    await _fetchOptimizedRoutes();
    configureTimezone();
    if (mounted) {
      setState(() {
        isLoading = false; // Ensure loading state is reset after all operations
      });
    }
  }

  void configureTimezone() {
    tz.initializeTimeZones();
  }

  DateTime getIsraelTime() {
    // Set the timezone to Israel
    final israelTimeZone = tz.getLocation('Asia/Jerusalem');
    return tz.TZDateTime.now(israelTimeZone);
  }

  DateTime calculateNextDayWithFixedTime() {
    DateTime currentTime =
        getIsraelTime(); // Use Israel time instead of system time
    if (isRunning) {
      print(currentTime);
      return currentTime; // If delivering now, use the current time
    }
    if (currentTime.hour < 12) {
      return currentTime; // Start today at 8:00 AM
    }
    // Check if today is Friday (5) or Saturday (6)
    if (currentTime.weekday == DateTime.friday ||
        currentTime.weekday == DateTime.saturday) {
      // Calculate the next Sunday
      int daysToAdd = 7 - currentTime.weekday; // Days to add to get to Sunday
      DateTime nextSunday = currentTime.add(Duration(days: daysToAdd));
      return DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 8,
          0); // Set to 8:00 AM Sunday
    }
    DateTime nextDay = currentTime.add(Duration(days: 1)); // Add 1 day
    return DateTime(
        nextDay.year, nextDay.month, nextDay.day, 8, 0); // Set time to 8:00 AM
  }

  Future<void> _fetchOptimizedRoutes() async {
    if (clients.isEmpty) {
      return;
    }

    try {
      // Construct waypoints
      final waypoints = clients
          .map((client) => '${client.lat},${client.lng}')
          .expand((location) => [
                location, // Client's location
                '${companyLocation['latitude']},${companyLocation['longitude']}' // Return to company
              ])
          .toList()
          .join('|');

// Construct the Directions API URL
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${companyLocation['latitude']},${companyLocation['longitude']}' // Start at company
        '&destination=${companyLocation['latitude']},${companyLocation['longitude']}' // End at company
        '&waypoints=optimize:false|$waypoints' // Preserve order of waypoints
        '&key=$apiKey', // API key
      );
      print('Waypoints: $waypoints');
      print('URL: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final legs = route['legs'];

          const Duration preparationTime = Duration(minutes: 30);
          const Duration handlingTime = Duration(minutes: 30);

          DateTime currentTime =
              calculateNextDayWithFixedTime().add(preparationTime);
          final optimizedClients = <Map<String, dynamic>>[];
          print("length= ${legs.length}");

          for (int i = 0; i < legs.length - 1; i += 2) {
            final deliveryLeg = legs[i];
            final travelTimeToClient =
                Duration(seconds: deliveryLeg['duration']['value']);
            print("traveltime= ${travelTimeToClient.inMinutes}");
            final deliveryLocation = deliveryLeg['end_location'];

            // Match the client for the delivery leg
            final matchingClient = clients.firstWhere(
              (client) =>
                  (client.lat - deliveryLocation['lat']).abs() < 0.0005 &&
                  (client.lng - deliveryLocation['lng']).abs() < 0.0005,
              orElse: () {
                throw Exception(
                    'No matching client found for location: $deliveryLocation');
              },
            );

            final arrivalTime = currentTime.add(travelTimeToClient);

            // Travel time back to the company (next leg)
            final returnLeg = legs[i + 1];
            final travelTimeBackToCompany =
                Duration(seconds: returnLeg['duration']['value']);

            optimizedClients.add({
              'client': matchingClient,
              'exitTime': currentTime,
              'arrivalTime': arrivalTime,
              'travelTimeToClient': travelTimeToClient,
              'travelTimeBackToCompany': travelTimeBackToCompany,
            });

            // Update currentTime
            currentTime = arrivalTime
                .add(handlingTime) // Handling at delivery location
                .add(travelTimeBackToCompany) // Travel back to the company
                .add(preparationTime); // Preparation for next delivery
          }

          setState(() {
            clients.clear();
            clients.addAll(optimizedClients.map((e) => e['client']));
            _clientTimes = optimizedClients.map((e) => e).toList();
            _returnTime = currentTime; // Final time after all deliveries
          });
        }
      }
    } catch (e) {
      debugPrint('Error in _fetchOptimizedRoutes: $e');
    }
  }

  Future<String> _getTravelTimeWithTraffic(
      google_maps.LatLng origin, google_maps.LatLng destination) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&waypoints=${companyLocation['latitude']},${companyLocation['longitude']}'
      '&mode=driving&departure_time=now&key=$apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final duration = data['routes'][0]['legs']
              .map((leg) =>
                  leg['duration_in_traffic']?['value'] ??
                  leg['duration']['value'])
              .reduce((a, b) => a + b);

          return '${(duration ~/ 60)} min'; // Convert to minutes
        }
      }
      return 'Error: ${response.statusCode}';
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

  Future<void> _updateClientStatusInFirestore(
      String clientId, String orderId, String status) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Update client status in the 'orders' collection
      final clientOrderRef = firestore
          .collection("clients")
          .doc(clientId)
          .collection("orders")
          .doc(orderId);
      await clientOrderRef.update({
        'status': status,
      });

      print("Client status updated to: $status in 'orders' collection");

      // Now update the status in the employee's 'dailyDeliveries' subcollection
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final employeeDocRef = firestore.collection('Employees').doc(user.uid);

        // Reference to the dailyDeliveries subcollection and update the client's status
        final dailyDeliveriesRef = employeeDocRef.collection('dailyDeliveries');
        final dailyDeliveryDoc = await dailyDeliveriesRef
            .where('clientId', isEqualTo: clientId)
            .where('orderId', isEqualTo: orderId)
            .limit(1)
            .get();

        if (dailyDeliveryDoc.docs.isNotEmpty) {
          // Update status in the dailyDeliveries subcollection
          final dailyDeliveryDocRef = dailyDeliveryDoc.docs.first.reference;
          await dailyDeliveryDocRef.update({
            'status': status,
          });

          print(
              "Client status updated to: $status in 'dailyDeliveries' subcollection");
        } else {
          print("No matching daily delivery document found for the client.");
        }
      } else {
        print("No authenticated user found.");
      }
    } catch (e) {
      print("Error updating client status: $e");
    }
  }

  void _startPreparingOrder(String clientId, String orderId) {
    setState(() {
      isRunningOrder = true;
    });

    // Assuming you have a method to update the client status in your database
    _updateClientStatusInFirestore(clientId, orderId, "בתהליך");
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
          if (!isLoading)
            clients.isEmpty
                ? Center(
                    child: const Text(
                      'לא נמצאו לקוחות להיום', // Message in Hebrew: "No clients found for today"
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Positioned.fill(
                    top: screenHeight * 0.1, // Adjust top padding for logo
                    child: ListView.builder(
                      itemCount: _clientTimes.isNotEmpty
                          ? _clientTimes.length
                          : clients.length,
                      itemBuilder: (context, index) {
                        if (_clientTimes.isNotEmpty) {
                          // Logic for _clientTimes-based display
                          final clientData = _clientTimes[index];
                          final client = clients[index];
                          final isExpanded = _expandedClientMap[index] ?? false;
                          final exitTime = clientData['exitTime'];
                          final arrivalTime = clientData['arrivalTime'];
                          final travelTimeToClient =
                              clientData['travelTimeToClient'];
                          final travelTimeBackToCompany =
                              clientData['travelTimeBackToCompany'];

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
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // Align text to start
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${index + 1}. ${client.fullName}',
                                                    style: TextStyle(
                                                      fontSize:
                                                          screenHeight * 0.025,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  if (exitTime != null)
                                                    Text(
                                                      'שעת יציאה משוערת: ${exitTime.hour}:${exitTime.minute.toString().padLeft(2, '0')}',
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize:
                                                              screenHeight *
                                                                  0.02),
                                                    ),
                                                  if (arrivalTime != null)
                                                    Text(
                                                      'זמן הגעה משוער: ${arrivalTime.hour}:${arrivalTime.minute.toString().padLeft(2, '0')}',
                                                      style: TextStyle(
                                                          color: Colors.amber,
                                                          fontSize:
                                                              screenHeight *
                                                                  0.02),
                                                    ),
                                                  if (travelTimeToClient !=
                                                      null)
                                                    Text(
                                                      'זמו נסיעה ללקוח: ${convertToHebrew('${travelTimeToClient.inMinutes} min')}',
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize:
                                                              screenHeight *
                                                                  0.02),
                                                    ),
                                                  if (travelTimeBackToCompany !=
                                                      null)
                                                    Text(
                                                      'זמן נסיעה חזרה: ${convertToHebrew('${travelTimeBackToCompany.inMinutes} min')}',
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize:
                                                              screenHeight *
                                                                  0.02),
                                                    ),
                                                  Text(
                                                    'כתובת: ${client.address}',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize:
                                                          screenHeight * 0.02,
                                                    ),
                                                  ),
                                                  Text(
                                                    'סטטוס הזמנה: ${client.status}',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize:
                                                          screenHeight * 0.02,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              _expandedClientMap[index] ?? false
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: Colors.white,
                                              size: screenHeight * 0.03,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
                                          borderRadius: BorderRadius.circular(
                                              screenHeight * 0.015),
                                          border: Border.all(
                                              color: Colors.white70, width: 1),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              screenHeight * 0.015),
                                          child: google_maps.GoogleMap(
                                            initialCameraPosition:
                                                google_maps.CameraPosition(
                                              target: LatLng(
                                                  client.lat, client.lng),
                                              zoom: 14,
                                            ),
                                            markers: {
                                              google_maps.Marker(
                                                markerId: google_maps.MarkerId(
                                                    client.fullName),
                                                position: LatLng(
                                                    client.lat, client.lng),
                                                infoWindow:
                                                    google_maps.InfoWindow(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Conditionally show the "Start Preparing" button when isPreparingOrder is false
                                          if (client.status != "בתהליך" &&
                                              client.status != "בדרך ללקוח")
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: screenHeight * 0.01,
                                                  horizontal:
                                                      screenWidth * 0.04,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          screenHeight * 0.015),
                                                ),
                                                backgroundColor:
                                                    Colors.greenAccent,
                                              ),
                                              icon: Icon(Icons.work,
                                                  size: screenHeight * 0.023),
                                              label: Text(
                                                'התחלת הכנת הזמנה',
                                                style: TextStyle(
                                                    fontSize:
                                                        screenHeight * 0.02),
                                              ),
                                              onPressed: () async {
                                                if (isRunningOrder) {
                                                  // Show Snackbar message if another order is running
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'ישנה הזמנה פעילה כבר, אנא חכה שהיא תסיים.'), // Missing quotes fixed
                                                      duration:
                                                          Duration(seconds: 3),
                                                    ),
                                                  );
                                                } else {
                                                  // Get employee's current location
                                                  LatLng currentLocation =
                                                      await EmployeeLocationPage()
                                                          .getEmployeeLocation(); // Get current location of the employee
                                                  // Calculate the distance from the company location
                                                  double distance =
                                                      EmployeeLocationPage()
                                                          .calculateDistance(
                                                    currentLocation.latitude,
                                                    currentLocation.longitude,
                                                    companyLocation[
                                                        'latitude']!,
                                                    companyLocation[
                                                        'longitude']!,
                                                  );

                                                  if (distance > 50) {
                                                    // Show Snackbar message if employee is more than 50 meters away
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'אתה צריך להיות בחברה כדי להתחיל את ההזמנה.'), // Missing quotes fixed
                                                        duration: Duration(
                                                            seconds: 3),
                                                      ),
                                                    );

                                                    // Optionally, you can show a "Navigate to Company" button here
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          AlertDialog(
                                                        title: Text(
                                                            "Navigate to Company"),
                                                        content: Text(
                                                            "You are too far from the company. Would you like to navigate?"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              _startNavigation(LatLng(
                                                                  companyLocation[
                                                                      'latitude']!,
                                                                  companyLocation[
                                                                      'longitude']!)); // Open Google Maps to navigate to the company
                                                            },
                                                            child: Text(
                                                                'Navigate'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                Text('Cancel'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    // Proceed with starting the order if within range
                                                    setState(() {
                                                      isRunningOrder = true;
                                                    });
                                                    client.status = "בתהליך";
                                                    _startPreparingOrder(
                                                        client.clientId,
                                                        client.orderId);
                                                  }
                                                }
                                              },
                                            ),

                                          // Conditionally show the "Start Journey" button when isPreparingOrder is true
                                          if (client.status == "בתהליך")
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: screenHeight * 0.01,
                                                  horizontal:
                                                      screenWidth * 0.04,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          screenHeight * 0.015),
                                                ),
                                                backgroundColor:
                                                    Colors.orangeAccent,
                                              ),
                                              icon: Icon(Icons.directions,
                                                  size: screenHeight * 0.025),
                                              label: Text(
                                                'התחלת נסיעה',
                                                style: TextStyle(
                                                    fontSize:
                                                        screenHeight * 0.022),
                                              ),
                                              onPressed: () {
                                                _startNavigation(LatLng(
                                                    client.lat,
                                                    client
                                                        .lng)); // Open Google Maps
                                                setState(() {
                                                  client.status =
                                                      "בדרך ללקוח"; // Update client status in your database to "Delivered"
                                                  isDeliveryStarted = true;
                                                });

                                                // Update the client status in Firestore after the delivery is done
                                                _updateClientStatusInFirestore(
                                                    client.clientId,
                                                    client.orderId,
                                                    "בדרך ללקוח");
                                              },
                                            ),

                                          // Conditionally display the "ההזמנה סופקה" button after the delivery has started
                                          if (isDeliveryStarted &&
                                              client.status == "בדרך ללקוח")
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: screenHeight * 0.01,
                                                  horizontal:
                                                      screenWidth * 0.04,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          screenHeight * 0.015),
                                                ),
                                                backgroundColor:
                                                    Colors.greenAccent,
                                              ),
                                              icon: Icon(Icons.check_circle,
                                                  size: screenHeight * 0.025),
                                              label: Text(
                                                'ההזמנה סופקה', // "Order Delivered"
                                                style: TextStyle(
                                                    fontSize:
                                                        screenHeight * 0.022),
                                              ),
                                              onPressed: () {
                                                // Optional: Show a Snackbar or any other feedback
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'ההזמנה סופקה בהצלחה!'), // "Order delivered successfully"
                                                    duration:
                                                        Duration(seconds: 3),
                                                  ),
                                                );
                                              },
                                            ),

                                          // The existing "Call" button
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                vertical: screenHeight * 0.01,
                                                horizontal: screenWidth * 0.05,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        screenHeight * 0.015),
                                              ),
                                              backgroundColor:
                                                  Colors.blueAccent,
                                            ),
                                            icon: Icon(Icons.phone,
                                                size: screenHeight * 0.025),
                                            label: Text(
                                              'התקשר',
                                              style: TextStyle(
                                                  fontSize:
                                                      screenHeight * 0.022),
                                            ),
                                            onPressed: () {
                                              _contactClient(
                                                  client.phoneNumber);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
          if (isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    strokeWidth: 3.0,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'מחפש לקוחות',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
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
      await launchUrl(
        phoneUrl,
        mode: LaunchMode.externalApplication, // Ensures it uses an external app
      );
    }
  }
}
