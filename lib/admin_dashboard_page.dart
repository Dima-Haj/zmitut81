import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customer_management_page.dart';
import 'delivery_management_page.dart';
import 'employee_management_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';

//import 'models/delivery.dart'; // Import the Delivery model
//import 'widgets/delivery_efficiency_graph.dart';

void main() => runApp(const AdminDashboardApp());

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AdminDashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminDashboardPageContent extends StatelessWidget {
  const AdminDashboardPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PageTitle(title: 'Dashboard'),
          const DeliveryOverviewWidget(),
          const PageTitle(title: 'Performance Metrics'),
          const PerformanceMetricsWidget(),
          const PageTitle(title: 'Live Map'),
          const MapWidget(),
        ],
      ),
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboardPage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    const CustomerManagementPage(),
    const AdminDashboardPageContent(),
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(color: Colors.white),
          _pages[_selectedIndex],
          Positioned(
            top: 38.0,
            left: 16.0,
            child: const DashboardMenu(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Solid white background for the bar
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5), // Thin top border
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Customers'),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping), label: 'Deliveries'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people), label: 'Employees'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(
              255, 41, 118, 251), // Black for selected items
          unselectedItemColor: Colors.black54, // Dark gray for unselected items
          backgroundColor: Colors.white, // Explicit white background here
          elevation: 0, // No shadow to ensure the border is visible
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  final String title;
  const PageTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class DeliveryOverviewWidget extends StatelessWidget {
  final int activeCount;
  final int pendingCount;
  final int completedCount;

  const DeliveryOverviewWidget({
    super.key,
    this.activeCount = 1,
    this.pendingCount = 5,
    this.completedCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final int totalDeliveries = activeCount + pendingCount + completedCount;
    final double completionPercentage =
        totalDeliveries > 0 ? completedCount / totalDeliveries : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Delivery Progress",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Center(
            child: CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 6.0,
              percent: completionPercentage,
              center: Text(
                '${(completionPercentage * 100).toInt()}%', // Bold percentage text
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold, // Set to bold
                ),
              ),
              progressColor: const Color.fromARGB(255, 41, 118, 251),
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusItem(Icons.local_shipping_outlined, "Active",
                  activeCount, Colors.blue),
              _buildDivider(),
              _buildStatusItem(
                  Icons.access_time, "Pending", pendingCount, Colors.orange),
              _buildDivider(),
              _buildStatusItem(Icons.check_circle_outline, "Completed",
                  completedCount, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String label, int count, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        Text('$count',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade300);
  }
}

class PerformanceMetricsWidget extends StatelessWidget {
  const PerformanceMetricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Column(
          // Placeholder for graph or metrics
          ),
    );
  }
}

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Default map values
    const double initialLatitude = 35.2271;
    const double initialLongitude = -80.8431;
    const double initialZoom = 7.0;

    // Debug logs for validation
    print(
        "Debug: Initial Latitude: ${initialLatitude.isFinite ? initialLatitude : 'Invalid'}");
    print(
        "Debug: Initial Longitude: ${initialLongitude.isFinite ? initialLongitude : 'Invalid'}");
    print(
        "Debug: Initial Zoom Level: ${initialZoom.isFinite ? initialZoom : 'Invalid'}");

    // Validate values and provide safe defaults
    final LatLng safeLatLng = LatLng(
      initialLatitude.isFinite ? initialLatitude : 0.0,
      initialLongitude.isFinite ? initialLongitude : 0.0,
    );
    final double safeZoom =
        initialZoom.isFinite && initialZoom > 0 ? initialZoom : 5.0;

    // Add screen size detection and adjust zoom dynamically for iPads
    final bool isLargeScreen =
        MediaQuery.of(context).size.width > 600; // Detect iPad
    final double adjustedZoom = isLargeScreen
        ? safeZoom - 2.0
        : safeZoom; // Reduce zoom for larger screens
    print("Debug: Adjusted Zoom Level: $adjustedZoom");

    return FlutterMap(
      options: MapOptions(
        initialCenter: safeLatLng,
        initialZoom: adjustedZoom,
        minZoom: 1.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          tileBounds: LatLngBounds(
            LatLng(-85.0, -180.0), // Southwest corner
            LatLng(85.0, 180.0), // Northeast corner
          ),
        ),
      ],
    );
  }
}

class DashboardMenu extends StatelessWidget {
  const DashboardMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, color: Colors.black),
      onSelected: (value) {
        if (value == 'Settings') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SettingsPage()));
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
              value: 'Notifications', child: Text('Notifications History')),
          const PopupMenuItem(
              value: 'Drivers Information', child: Text('Drivers Information')),
          const PopupMenuItem(
              value: 'Delivery Reports', child: Text('Delivery Reports')),
          const PopupMenuItem(value: 'Settings', child: Text('Settings')),
        ];
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color iconColor = const Color.fromARGB(255, 62, 55, 198);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 242, 242, 247),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text('User Roles & Permissions'),
              trailing: Icon(Icons.arrow_forward_ios),
            )
          ],
        ),
      ),
    );
  }
}
