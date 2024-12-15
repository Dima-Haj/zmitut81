import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customer_management_page.dart';
import 'delivery_management_page.dart';
import 'employee_management_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> managerDetails;

  const AdminDashboard({super.key, required this.managerDetails});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 1; // Default index for the dashboard

  late String firstName;
  late String email;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Validate managerDetails and assign default values if necessary
    firstName = widget.managerDetails['firstName'] ?? 'Manager';
    email = widget.managerDetails['email'] ?? 'Unknown Email';

    _pages = [
      const CustomerManagementPage(),
      const DashboardPage(), // Use a proper placeholder or actual page
      const DeliveryManagementPage(),
      const EmployeeManagementPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/image1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color.fromARGB(255, 42, 42, 42).withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Foreground Content
          Column(
            children: [
              AppBar(
                title: Text(
                  'Welcome, $firstName',
                  style: TextStyle(
                    fontSize: screenHeight * 0.027,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(221, 255, 255, 255),
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 141, 126, 106),
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: screenHeight * 0.03),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: screenHeight * 0.03),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, size: screenHeight * 0.03),
            label: 'Deliveries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: screenHeight * 0.03),
            label: 'Employees',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 131, 107, 81),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedLabelStyle: TextStyle(fontSize: screenHeight * 0.015),
        unselectedLabelStyle: TextStyle(
          fontSize: screenHeight * 0.013,
          color: const Color.fromARGB(255, 120, 120, 120),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: screenHeight * 0.03),
          _buildDeliveryOverviewWidget(screenHeight),

          // _buildPerformanceMetricsWidget(screenHeight),
        ],
      ),
    );
  }

  Widget _buildDeliveryOverviewWidget(double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.03),
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Icon
          Center(
            child: Row(
              mainAxisSize: MainAxisSize
                  .min, // Ensures the row takes only the needed space
              children: [
                SizedBox(width: screenHeight * 0.01),
                Text(
                  "Delivery Activity",
                  style: TextStyle(
                    fontSize: screenHeight * 0.026,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.02),
          // Completed Deliveries Progress Bar
          Row(
            children: [
              Icon(Icons.check_circle,
                  color: Colors.blue, size: screenHeight * 0.025),
              SizedBox(width: screenHeight * 0.01),
              Text(
                "Completed",
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          LinearProgressIndicator(
            value: 30 / 50, // Example: 30 completed out of 50
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
            minHeight: screenHeight * 0.015,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "16 / 30",
            style: TextStyle(
              fontSize: screenHeight * 0.018,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          // Active and Pending Deliveries
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActivePendingCard(
                title: "Active",
                count: 12,
                color: Colors.green,
                icon: Icons.local_shipping,
                screenHeight: screenHeight,
              ),
              Container(
                width: 1, // Thin line between Active and Pending
                height: screenHeight * 0.05,
                color: Colors.grey.shade400,
              ),
              _buildActivePendingCard(
                title: "Pending",
                count: 5,
                color: Colors.orange,
                icon: Icons.access_time,
                screenHeight: screenHeight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivePendingCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required double screenHeight,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: screenHeight * 0.02, color: color),
              SizedBox(width: screenHeight * 0.005),
              Text(
                title,
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: screenHeight * 0.025,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      String status, IconData icon, int count, double screenHeight) {
    return Column(
      children: <Widget>[
        Icon(icon, size: screenHeight * 0.04, color: Colors.blue),
        SizedBox(height: screenHeight * 0.005),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          status,
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
      ],
    );
  }
}

class DeliveryOverviewWidget extends StatelessWidget {
  final double screenHeight;
  final int activeCount;
  final int pendingCount;
  final int completedCount;

  const DeliveryOverviewWidget({
    super.key,
    required this.screenHeight,
    this.activeCount = 12,
    this.pendingCount = 5,
    this.completedCount = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.03),
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
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
  final double iconSize;

  const DeliveryStatusCard({
    super.key,
    required this.status,
    required this.icon,
    required this.count,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon,
            size: iconSize, color: const Color.fromARGB(255, 141, 126, 106)),
        SizedBox(height: iconSize * 0.2),
        Text(
          count.toString(),
          style: TextStyle(fontSize: iconSize, fontWeight: FontWeight.bold),
        ),
        Text(status),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final double fontSize;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(fontSize),
        margin: EdgeInsets.symmetric(horizontal: fontSize),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(fontSize * 1.5),
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
              style: TextStyle(fontSize: fontSize),
            ),
            SizedBox(height: fontSize * 0.5),
            Text(
              value,
              style: TextStyle(
                  fontSize: fontSize * 1.2, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildMap(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: screenHeight * 0.03),
          _buildDeliveryOverviewWidget(screenHeight),
          SizedBox(height: screenHeight * 0.03),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Text(
              'Live Delivery Map',
              style: GoogleFonts.exo2(
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 223, 223, 223),
              ),
            ),
          ),
          _buildLiveMap(screenHeight),
          SizedBox(height: screenHeight * 0.03),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Text(
              'Delivery Schedule',
              style: GoogleFonts.exo2(
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 223, 223, 223),
              ),
            ),
          ),
          _buildCalendar(screenHeight),
        ],
      ),
    );
  }

  Widget _buildDeliveryOverviewWidget(double screenHeight) {
    // Same as the previous implementation
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.03),
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Cargo Activity",
              style: TextStyle(
                fontSize: screenHeight * 0.026,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          LinearProgressIndicator(
            value: 30 / 50,
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
            minHeight: screenHeight * 0.015,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "16 / 30",
            style: TextStyle(
              fontSize: screenHeight * 0.018,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
        ],
      ),
    );
  }

  Widget _buildLiveMap(double screenHeight) {
    return Container(
      height: screenHeight * 0.4, // Adjust height based on your layout
      margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(37.7749, -122.4194), // Replace with your coordinates
            zoom: 12.0,
          ),
          markers: {
            const Marker(
              markerId: MarkerId("delivery1"),
              position: LatLng(37.7749, -122.4194), // Example position
              infoWindow: InfoWindow(title: "Delivery 1", snippet: "On route"),
            ),
          },
          onMapCreated: (GoogleMapController controller) {
            // Add any map initialization logic here
          },
        ),
      ),
    );
  }

  Widget _buildCalendar(double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.03),
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: TableCalendar(
        focusedDay: DateTime.now(),
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        calendarFormat: CalendarFormat.month,
        onDaySelected: (selectedDay, focusedDay) {
          // Add your logic to fetch or display data for selectedDay
        },
        headerStyle: HeaderStyle(
          titleTextStyle: TextStyle(
            fontSize: screenHeight * 0.02,
            fontWeight: FontWeight.bold,
          ),
          formatButtonVisible: false,
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
