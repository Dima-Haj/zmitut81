import 'package:flutter/material.dart';
import 'full_calendar_page.dart'; // Import the FullCalendarPage from its file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  int pendingCount = 0;
  int activeCount = 0;
  int completedCount = 0;
  int total = 0;

  @override
  void initState() {
    super.initState();
    firstName = widget.managerDetails['firstName'] ?? 'Manager';
    email = widget.managerDetails['email'] ?? 'Unknown Email';

    // Fetch the delivery counts
    _fetchDeliveryCounts();
    _fetchPreviousDeliveries();
  }

  void _fetchDeliveryCounts() async {
    try {
      // Get the current logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // If the user is not logged in
        print('User is not logged in');
        return;
      }

      // Get the UID of the logged-in user
      String userId = user.uid;
      print("Logged in user UID: $userId");

      // Fetch all deliveries in "dailyDeliveries" collection across all employees
      QuerySnapshot employeesSnapshot = await FirebaseFirestore.instance
          .collection('Employees') // The root collection for all employees
          .get(); // Fetch all employee documents

      int newCount = 0;
      int activeCount = 0;

      int total = 0;

      // Iterate through each employee document
      for (var employeeDoc in employeesSnapshot.docs) {
        // For each employee, fetch their "dailyDeliveries" sub-collection
        QuerySnapshot deliveriesSnapshot = await FirebaseFirestore.instance
            .collection('Employees')
            .doc(employeeDoc.id) // Employee document ID
            .collection(
                'dailyDeliveries') // Sub-collection containing deliveries
            .get();

        // Iterate through all the fetched deliveries and count by status
        for (var doc in deliveriesSnapshot.docs) {
          String status = doc['status']; // Get the status field

          if (status == 'חדשה') {
            newCount++;
          } else if (status == 'בדרך') {
            activeCount++;
          }
        }
      }
      // Update total deliveries count (pending + active)
      total += newCount + activeCount;

      // Update the UI with the counts
      if (mounted) {
        setState(() {
          this.pendingCount = newCount;
          this.activeCount = activeCount;
          //this.completedCount = completedCount;
          this.total = total; // Set the total deliveries value
        });
      }
    } catch (e) {
      print('Error fetching delivery data: $e');
    }
  }

  void _fetchPreviousDeliveries() async {
    try {
      // Get the current logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // If the user is not logged in
        print('User is not logged in');
        return;
      }

      // Get the UID of the logged-in user
      String userId = user.uid;
      print("Logged in user UID: $userId");

      // Fetch all deliveries in "previousDeliveries" collection across all clients
      QuerySnapshot clientsSnapshot = await FirebaseFirestore.instance
          .collection('clients') // The root collection for all clients
          .get(); // Fetch all client documents

      int completedCount = 0;

      // Iterate through each client document
      for (var clientDoc in clientsSnapshot.docs) {
        // For each client, fetch their "previousDeliveries" sub-collection
        QuerySnapshot previousDeliveriesSnapshot = await FirebaseFirestore
            .instance
            .collection('clients')
            .doc(clientDoc.id) // client document ID
            .collection(
                'previousDeliveries') // Sub-collection containing previous deliveries
            .get();

        // Iterate through all the fetched deliveries and count by status
        for (var doc in previousDeliveriesSnapshot.docs) {
          String status = doc['status']; // Get the status field

          if (status == 'נמסר') {
            completedCount++;
          }
        }
      }

      // Update the UI with the count of completed deliveries
      if (mounted) {
        setState(() {
          this.completedCount = completedCount; // Ensure UI gets updated
        });
      }
    } catch (e) {
      print('Error fetching delivery data: $e');
    }
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
                child: DashboardPage(
                  categories: widget.categories,
                  completedCount: completedCount,
                  activeCount: activeCount,
                  pendingCount: pendingCount,
                  totalCount: total,
                ),
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
  final int completedCount;
  final int activeCount;
  final int pendingCount;
  final int totalCount;

  const DashboardPage({
    super.key,
    required this.categories,
    required this.completedCount,
    required this.activeCount,
    required this.pendingCount,
    required this.totalCount,
  });

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
          _buildDeliveryOverviewWidget(screenHeight, categories, context),
        ],
      ),
    );
  }

  Widget _buildDeliveryOverviewWidget(double screenHeight,
      List<Map<String, dynamic>> categories, BuildContext context) {
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
              InkWell(
                onTap: () {
                  // Navigate to the Completed Orders Page when tapped
                  Navigator.push(
                    context, // The correct context is the one provided by the widget's build method
                    MaterialPageRoute(
                      builder: (context) =>
                          CompletedOrdersPage(), // Replace with your actual page
                    ),
                  );
                },
                child: Row(
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
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          LinearProgressIndicator(
            value: totalCount > 0
                ? completedCount / totalCount
                : 0.0, // Dynamically calculate progress
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
            minHeight: screenHeight * 0.015,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "$completedCount / $totalCount", // Completed deliveries count
            style: TextStyle(
              fontSize: screenHeight * 0.018,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: screenHeight * 0.03),
          // Active and Pending Deliveries
          SizedBox(height: screenHeight * 0.03),
          // Active and Pending Deliveries
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center the content horizontally
            children: [
              // Wrap Expanded inside a Flex or Column to ensure it's used correctly
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context, // The correct context is the one provided by the widget's build method
                      MaterialPageRoute(
                        builder: (context) => ActiveOrdersPage(),
                      ),
                    );
                  },
                  child: _buildActivePendingCard(
                    title: "פעיל",
                    count: activeCount,
                    color: Colors.green,
                    icon: Icons.local_shipping,
                    screenHeight: screenHeight,
                  ),
                ),
              ),

              SizedBox(
                  width:
                      screenHeight * 0.02), // Add some space between the cards
              // Wrap Expanded inside a Flex or Column to ensure it's used correctly
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context, // The correct context is the one provided by the widget's build method
                      MaterialPageRoute(
                        builder: (context) => PendingOrdersPage(),
                      ),
                    );
                  },
                  child: _buildActivePendingCard(
                    title: "בהמתנה",
                    count: pendingCount,
                    color: Colors.orange,
                    icon: Icons.access_time,
                    screenHeight: screenHeight,
                  ),
                ),
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
    return Column(
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

class PendingOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הזמנות בהמתנה'),
        backgroundColor: const Color.fromARGB(255, 141, 126, 106),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('Employees')
            .get() // Fetching the Employees collection
            .then((QuerySnapshot snapshot) {
          List<Future<QuerySnapshot>> deliveryFetches = [];

          // Iterate through all employees and fetch their daily deliveries
          for (var employeeDoc in snapshot.docs) {
            deliveryFetches.add(
              FirebaseFirestore.instance
                  .collection('Employees')
                  .doc(employeeDoc.id)
                  .collection('dailyDeliveries')
                  .where('status', isEqualTo: 'חדשה') // Only "חדשה" deliveries
                  .get(),
            );
          }

          // Combine all fetched deliveries into one list
          return Future.wait(deliveryFetches);
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching deliveries: ${snapshot.error}'));
          }

          final allPendingDeliveries = <QueryDocumentSnapshot>[];

          // Combine all the documents from each employee's deliveries collection
          for (var result in snapshot.data as List<QuerySnapshot>) {
            allPendingDeliveries.addAll(result.docs);
          }

          if (allPendingDeliveries.isEmpty) {
            return const Center(child: Text('אין הזמנות בהמתנה.'));
          }

          return ListView.builder(
            itemCount: allPendingDeliveries.length,
            itemBuilder: (context, index) {
              final order =
                  allPendingDeliveries[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(order['product'] ?? 'No product'),
                subtitle: Text(order['clientName'] ?? 'No client name'),
                trailing: Text(order['date'] ?? 'No date'),
              );
            },
          );
        },
      ),
    );
  }
}

class ActiveOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הזמנות פעילות'),
        backgroundColor: const Color.fromARGB(255, 141, 126, 106),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('Employees')
            .get() // Fetch all employee documents
            .then((employeesSnapshot) async {
          List<QuerySnapshot> activeDeliveriesSnapshots = [];
          for (var employeeDoc in employeesSnapshot.docs) {
            // Fetch "dailyDeliveries" sub-collection for each employee
            var deliveriesSnapshot = await FirebaseFirestore.instance
                .collection('Employees')
                .doc(employeeDoc.id) // Employee document ID
                .collection('dailyDeliveries')
                .where('status',
                    isEqualTo: 'בדרך') // Fetch "בדרך" deliveries for active
                .get();

            activeDeliveriesSnapshots.add(deliveriesSnapshot);
          }
          return activeDeliveriesSnapshots;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching deliveries'));
          }

          // Flatten the active deliveries data
          final List<QueryDocumentSnapshot> activeDeliveries = [];
          for (var deliveriesSnapshot in snapshot.data!) {
            activeDeliveries.addAll(deliveriesSnapshot.docs);
          }

          if (activeDeliveries.isEmpty) {
            return const Center(child: Text('אין הזמנות פעילות.'));
          }

          return ListView.builder(
            itemCount: activeDeliveries.length,
            itemBuilder: (context, index) {
              final order =
                  activeDeliveries[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(order['product'] ?? 'No product'),
                subtitle: Text(order['clientName'] ?? 'No client name'),
                trailing: Text(order['date'] ?? 'No date'),
              );
            },
          );
        },
      ),
    );
  }
}

class CompletedOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הזמנות שהושלמו'),
        backgroundColor: const Color.fromARGB(255, 141, 126, 106),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('clients') // Fetch all clients
            .get()
            .then((clientsSnapshot) async {
          List<QuerySnapshot> completedDeliveriesSnapshots = [];

          for (var clientDoc in clientsSnapshot.docs) {
            // Check if "previousDeliveries" sub-collection exists for each client
            var deliveriesSnapshot = await FirebaseFirestore.instance
                .collection('clients')
                .doc(clientDoc.id) // Client document ID
                .collection('previousDeliveries') // Sub-collection
                .where('status', isEqualTo: 'נמסר') // Fetch "נמסר" deliveries
                .get();

            // Only add the snapshot if the "previousDeliveries" collection exists
            if (deliveriesSnapshot.docs.isNotEmpty) {
              completedDeliveriesSnapshots.add(deliveriesSnapshot);
            }
          }

          // Flatten the deliveries data from all clients
          List<QueryDocumentSnapshot> allCompletedDeliveries = [];
          for (var snapshot in completedDeliveriesSnapshots) {
            allCompletedDeliveries.addAll(snapshot.docs);
          }

          return allCompletedDeliveries;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching deliveries'));
          }

          final allCompletedDeliveries =
              snapshot.data as List<QueryDocumentSnapshot>;

          if (allCompletedDeliveries.isEmpty) {
            return const Center(child: Text('אין הזמנות שהושלמו.'));
          }

          return ListView.builder(
            itemCount: allCompletedDeliveries.length,
            itemBuilder: (context, index) {
              final order =
                  allCompletedDeliveries[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text(order['name'] ?? 'No name'),
                subtitle: Text(order['product'] ?? 'No product'),
                trailing: Text(order['Date'] ?? 'No date'),
              );
            },
          );
        },
      ),
    );
  }
}
