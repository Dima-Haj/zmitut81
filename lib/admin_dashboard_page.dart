import 'package:flutter/material.dart';
import 'full_calendar_page.dart'; // Import the FullCalendarPage from its file

class AdminDashboardPage extends StatefulWidget {
  final Map<String, dynamic> managerDetails;
  final List<Map<String, dynamic>> categories;

  const AdminDashboardPage({
    super.key,
    required this.managerDetails,
    required this.categories,
  });

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboardPage> {
  late String firstName;
  late String email;

  @override
  void initState() {
    super.initState();
    firstName = widget.managerDetails['firstName'] ?? 'Manager';
    email = widget.managerDetails['email'] ?? 'Unknown Email';
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
          Column(
            children: [
              AppBar(
                title: Text(
                  'שלום, $firstName',
                  style: TextStyle(
                    fontSize: screenHeight * 0.027,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(221, 255, 255, 255),
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 141, 126, 106),
              ),
              Expanded(
                child: DashboardPage(categories: widget.categories),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const DashboardPage({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: screenHeight * 0.03),
          _buildDeliveryOverviewWidget(screenHeight, categories),
        ],
      ),
    );
  }

  Widget _buildDeliveryOverviewWidget(
      double screenHeight, List<Map<String, dynamic>> categories) {
    int completed = 30;
    int total = 50;
    int active = 12;
    int pending = 5;

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: screenHeight * 0.01),
                Text(
                  "פעילות משלוח",
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
                "הושלם",
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
            value: completed / total,
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
            minHeight: screenHeight * 0.015,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "$completed / $total",
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
                title: "פעיל",
                count: active,
                color: Colors.green,
                icon: Icons.local_shipping,
                screenHeight: screenHeight,
              ),
              Container(
                width: 1,
                height: screenHeight * 0.05,
                color: Colors.grey.shade400,
              ),
              _buildActivePendingCard(
                title: "בהמתנה",
                count: pending,
                color: Colors.orange,
                icon: Icons.access_time,
                screenHeight: screenHeight,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          DeliveryCalendarWidget(categories: categories),
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
}

class DeliveryCalendarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const DeliveryCalendarWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    Map<DateTime, List<String>> eventMap = {};

    for (var category in categories) {
      if (category.containsKey('Date')) {
        DateTime deliveryDate = DateTime.parse(category['Date']);
        deliveryDate =
            DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day);
        String deliveryDetails = category['product'];

        if (eventMap.containsKey(deliveryDate)) {
          eventMap[deliveryDate]!.add(deliveryDetails);
        } else {
          eventMap[deliveryDate] = [deliveryDetails];
        }
      }
    }

    DateTime today = DateTime.now();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullCalendarPage(eventMap: eventMap),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "היום",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "${today.day}/${today.month}/${today.year}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: eventMap[today]?.map((e) => Text(e)).toList() ??
                  [const Text("No deliveries")],
            ),
          ],
        ),
      ),
    );
  }
}
