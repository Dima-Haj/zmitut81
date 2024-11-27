import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customer_management_page.dart';
import 'delivery_management_page.dart';
import 'employee_management_page.dart';

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
  late final List<Widget> _pages = [
    const CustomerManagementPage(),
    AdminDashboard(
      managerDetails: widget.managerDetails,
    ),
    const DeliveryManagementPage(),
    const EmployeeManagementPage(),
  ];

  @override
  void initState() {
    super.initState();

    // Validate managerDetails and assign default values if necessary
    firstName = widget.managerDetails['firstName'] ?? 'Manager';
    email = widget.managerDetails['email'] ?? 'Unknown Email';

    // Log for debugging purposes
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

// I TRIED TO CHANGE THE BAR BACKGROUND TO
//WHITE BUT ITS NOT RESPONDING SHELEEE!
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $firstName',
              style: GoogleFonts.exo2(
                fontSize: screenHeight * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 141, 126, 106),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
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

class PageTitle extends StatelessWidget {
  final String title;
  const PageTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/image1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.65),
                  BlendMode.darken,
                ),
              ),
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: screenHeight * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Text(
                      'Delivery Overview',
                      style: GoogleFonts.exo2(
                        fontSize: screenHeight * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  DeliveryOverviewWidget(screenHeight: screenHeight),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Text(
                      'Performance Metrics',
                      style: GoogleFonts.exo2(
                        fontSize: screenHeight * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  PerformanceMetricsWidget(screenHeight: screenHeight),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DeliveryOverviewWidget extends StatelessWidget {
  final double screenHeight;
  int activeCount = 5;
  int pendingCount = 8;
  int completedCount = 7;
  DeliveryOverviewWidget({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    final int totalDeliveries = activeCount + pendingCount + completedCount;
    final double completionPercentage =
        totalDeliveries > 0 ? completedCount / totalDeliveries : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.03),
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DeliveryStatusCard(
            status: "Active",
            icon: Icons.local_shipping,
            count: 12,
            iconSize: screenHeight * 0.04,
          ),
          DeliveryStatusCard(
            status: "Pending",
            icon: Icons.access_time,
            count: 5,
            iconSize: screenHeight * 0.04,
          ),
          DeliveryStatusCard(
            status: "Completed",
            icon: Icons.check_circle,
            count: 30,
            iconSize: screenHeight * 0.04,
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
  final double screenHeight;

  const PerformanceMetricsWidget({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.03),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MetricCard(
                  title: "Delay Rate",
                  value: "30%",
                  fontSize: screenHeight * 0.02),
              MetricCard(
                  title: "On-time Rate",
                  value: "90%",
                  fontSize: screenHeight * 0.02),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MetricCard(
                  title: "Return Rate",
                  value: "20%",
                  fontSize: screenHeight * 0.02),
              MetricCard(
                  title: "Avg Cost/Delivery",
                  value: "\$250",
                  fontSize: screenHeight * 0.02),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final double fontSize;

  const MetricCard(
      {super.key,
      required this.title,
      required this.value,
      required this.fontSize});

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
}
