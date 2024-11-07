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
    return const MaterialApp(
      home: AdminDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 1; // Default index for dashboard

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
        selectedItemColor: const Color.fromARGB(255, 62, 55, 198),
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

class AdminDashboardPageContent extends StatelessWidget {
  const AdminDashboardPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color.fromARGB(255, 242, 242, 247), // Background color
        ),
        SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
                // image: DecorationImage(
                //   image: const AssetImage('assets/images/image1.png'),
                //   fit: BoxFit.cover,
                //   colorFilter: ColorFilter.mode(
                //     Colors.black.withOpacity(0.65),
                //     BlendMode.darken,
                //   ),
                // ),

                ),
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
                      style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 48, 48, 48)),
                    ),
                  ),
                  const DeliveryOverviewWidget(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Performance Metrics',
                      style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 48, 48, 48)),
                    ),
                  ),
                  const PerformanceMetricsWidget(),
                  Padding(
                    padding: const EdgeInsets.all(19.0),
                    child: Text(
                      'Live Map',
                      style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 48, 48, 48)),
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
                if (value == 'Settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
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

class DeliveryOverviewWidget extends StatelessWidget {
  const DeliveryOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(31, 39, 39, 39),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DeliveryStatusCard(
            status: "Active",
            icon: Icons.local_shipping,
            count: 1,
            iconColor: const Color.fromARGB(255, 36, 101, 241),
            iconSize: 27.0,
          ),
          DeliveryStatusCard(
            status: "Pending",
            icon: Icons.access_time_filled,
            count: 5,
            iconColor: const Color.fromARGB(255, 36, 101, 241),
            iconSize: 27.0,
          ),
          DeliveryStatusCard(
            status: "Completed",
            icon: Icons.check_circle,
            count: 3,
            iconColor: const Color.fromARGB(255, 36, 101, 241),
            iconSize: 27.0,
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
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0), // Added padding for spacing
          child: Stack(
            clipBehavior:
                Clip.none, // Allows badge to extend beyond icon bounds
            children: [
              Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
              Positioned(
                top: -10, // Adjusted values for better alignment
                right: -7,
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  width: 20, // Fixed width
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        255, 255, 255, 255), // Circle color
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(
                          255, 36, 101, 241), // Border color
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Color.fromARGB(
                            255, 62, 55, 198), // Green text color
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 0.9,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          status,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class PerformanceMetricsWidget extends StatelessWidget {
  const PerformanceMetricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MetricCard(title: "Delay Rate", value: "30%"),
              MetricCard(title: "Return Rate", value: "90%"),
            ],
          ),
          SizedBox(height: 10),
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
      body: Container(
        color: const Color.fromARGB(
            255, 242, 242, 247), // Light lavender background color
        child: Stack(
          children: [
            // Background image or other widgets can go here if needed
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: screenHeight * 0.75, // Adjust the height as needed
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.1),
                    topRight: Radius.circular(screenWidth * 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 55),
                      ListTile(
                        leading:
                            Icon(Icons.admin_panel_settings, color: iconColor),
                        title: Text(
                          'User Roles & Permissions',
                          style: GoogleFonts.openSans(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle user roles settings
                        },
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.notifications, color: iconColor),
                        title: Text(
                          'Notification Preferences',
                          style: GoogleFonts.openSans(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle notification settings
                        },
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.settings, color: iconColor),
                        title: Text(
                          'System Configurations',
                          style: GoogleFonts.openSans(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle system configurations
                        },
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.logout, color: iconColor),
                        title: Text(
                          'Logout',
                          style: GoogleFonts.openSans(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle Logout
                        },
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.delete, color: iconColor),
                        title: Text(
                          'Delete Account',
                          style: GoogleFonts.openSans(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle Delete Account
                        },
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.bug_report, color: iconColor),
                        title: Text(
                          'Report a bug',
                          style: GoogleFonts.openSans(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Handle reporting a bug
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
