import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customer_management_page.dart';
import 'delivery_management_page.dart';
import 'employee_management_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const AdminDashboardApp());

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AdminDashboardPage(), // Load AdminDashboardPage, not AdminDashboard
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboardPage> {
  int _selectedIndex = 1; // Default index for dashboard

  final List<Widget> _pages = [
    const CustomerManagementPage(),
    AdminDashboard(),
    const DeliveryManagementPage(),
    const EmployeeManagementPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 22),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: 22),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, size: 22),
            label: 'Deliveries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: 22),
            label: 'Employees',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 131, 107, 81),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(
            fontSize: 9, color: Color.fromARGB(255, 120, 120, 120)),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Delivery Time Efficiency',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 100, // Fixed height for the graph container
            child: DeliveryEfficiencyGraph(deliveries: sampleDeliveries),
          ),
          // Add more elements here if needed
        ],
      ),
    );
  }
}

class AdminDashboardPageContent extends StatelessWidget {
  const AdminDashboardPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color.fromARGB(255, 242, 242, 247),
        ),
        SizedBox.expand(
          child: Container(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(top: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Delivery Overview',
                      style: GoogleFonts.exo2(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const DeliveryOverviewWidget(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Performance Metrics',
                      style: GoogleFonts.exo2(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const PerformanceMetricsWidget(),
                  Padding(
                    padding: const EdgeInsets.all(19.0),
                    child: Text(
                      'Live Map',
                      style: GoogleFonts.exo2(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const MapWidget(),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 38.0,
          left: 16.0,
          child: Container(
            color: const Color.fromARGB(0, 216, 214, 214),
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'Notifications':
                    break;
                  case 'Drivers Information':
                    break;
                  case 'Delivery Reports':
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'Notifications',
                    child: Container(
                      color: Colors.transparent,
                      child: const Text(
                        'Notifications History',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Drivers Information',
                    child: Container(
                      color: Colors.transparent,
                      child: const Text(
                        'Drivers Information',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Delivery Reports',
                    child: Container(
                      color: Colors.transparent,
                      child: const Text(
                        'Delivery Reports',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Settings',
                    child: Container(
                      color: Colors.transparent,
                      child: const Text(
                        'Settings',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ];
              },
            ),
          ),
        ),
      ],
    );
  }
}

// The rest of the widgets (DeliveryOverviewWidget, DeliveryStatusCard, PerformanceMetricsWidget, MapWidget, etc.) remain unchanged

class DeliveryOverviewWidget extends StatelessWidget {
  const DeliveryOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DeliveryStatusCard(
            status: "Active",
            icon: Icons.local_shipping,
            count: 12,
            iconColor: const Color.fromARGB(255, 141, 126, 106),
            iconSize: 30.0,
          ),
          DeliveryStatusCard(
            status: "Pending",
            icon: Icons.access_time,
            count: 5,
            iconColor: const Color.fromARGB(255, 141, 126, 106),
            iconSize: 30.0,
          ),
          DeliveryStatusCard(
            status: "Completed",
            icon: Icons.check_circle,
            count: 30,
            iconColor: const Color.fromARGB(255, 141, 126, 106),
            iconSize: 30.0,
          ),
        ],
      ),
    );
  }
}

class DeliveryStatusCard extends StatelessWidget {
  final String status;
  final IconData icon;
  final int count;
  final Color iconColor;
  final double iconSize;

  const DeliveryStatusCard({
    super.key,
    required this.status,
    required this.icon,
    required this.count,
    required this.iconColor,
    this.iconSize = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerManagementPage(),
          ),
        );
      },
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(status),
        ],
      ),
    );
  }
}

class PerformanceMetricsWidget extends StatelessWidget {
  const PerformanceMetricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MetricCard(title: "Delay Rate", value: "30%"),
              MetricCard(title: "On-time Rate", value: "90%"),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100, // Set a fixed height for the graph
            child: DeliveryEfficiencyGraph(
              deliveries: [
                Delivery(
                  id: 'D1',
                  scheduledTime:
                      DateTime.now().subtract(const Duration(hours: 2)),
                  actualTime: DateTime.now()
                      .subtract(const Duration(hours: 1, minutes: 30)),
                  status: 'delayed',
                ),
                Delivery(
                  id: 'D2',
                  scheduledTime:
                      DateTime.now().subtract(const Duration(hours: 3)),
                  actualTime: DateTime.now()
                      .subtract(const Duration(hours: 2, minutes: 45)),
                  status: 'on time',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Define the Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color iconColor = const Color.fromARGB(255, 62, 55, 198);
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130.0), // Increase the height
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 242, 242, 247),
          automaticallyImplyLeading: false, // Disable default leading arrow
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(
                top: 60.0, left: 18.0), // Adjust padding as needed
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Color.fromARGB(255, 48, 48, 48)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Transform.translate(
                  offset: const Offset(
                      -30, 60), // Adjust Offset for desired position
                  child: Text(
                    'Settings',
                    style: GoogleFonts.notoSans(
                      fontSize: 27,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 48, 48, 48),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const MetricCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

@override
class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(35.217018, 31.771959),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FullScreenMap(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenMap extends StatelessWidget {
  const FullScreenMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full Screen Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(35.217018, 31.771959),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
        ],
      ),
    );
  }
}

Future<void> _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}
