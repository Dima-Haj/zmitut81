import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';

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

    // Fetch delivery data
    _fetchDeliveryCounts();
    _fetchPreviousDeliveries();
  }

  Future<List<Map<String, dynamic>>> _fetchTodaysDeliveries() async {
    try {
      // Get today's start and end times
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      List<Map<String, dynamic>> deliveries = [];

      // Fetch all employees
      QuerySnapshot employeesSnapshot =
          await FirebaseFirestore.instance.collection('Employees').get();

      for (var employeeDoc in employeesSnapshot.docs) {
        // Fetch daily deliveries for the employee
        QuerySnapshot deliveriesSnapshot = await FirebaseFirestore.instance
            .collection('Employees')
            .doc(employeeDoc.id)
            .collection('dailyDeliveries')
            .get();

        for (var doc in deliveriesSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String? departureTimeString = data['departureTime'];

          if (departureTimeString != null) {
            try {
              // Parse the departureTime string into a DateTime object
              DateTime departureTime = DateTime.parse(departureTimeString);

              // Check if the departure time falls within today's range
              if (departureTime.isAfter(startOfDay) &&
                  departureTime.isBefore(endOfDay)) {
                deliveries.add(data);
              }
            } catch (e) {
              print('Error parsing departureTime: $e');
            }
          }
        }
      }

      //print("Deliveries found: ${deliveries.length}");
      return deliveries;
    } catch (e) {
      print('Error fetching today\'s deliveries: $e');
      return [];
    }
  }

  void _fetchDeliveryCounts() async {
    try {
      QuerySnapshot employeesSnapshot =
          await FirebaseFirestore.instance.collection('Employees').get();

      int newCount = 0;
      int activeCount = 0;

      for (var employeeDoc in employeesSnapshot.docs) {
        QuerySnapshot deliveriesSnapshot = await FirebaseFirestore.instance
            .collection('Employees')
            .doc(employeeDoc.id)
            .collection('dailyDeliveries')
            .get();

        for (var doc in deliveriesSnapshot.docs) {
          String status = doc['status'];

          if (status == 'חדשה') {
            newCount++;
          } else if (status == 'בדרך' || status == 'בתהליך') {
            activeCount++;
          }
        }
      }

      setState(() {
        pendingCount = newCount;
        this.activeCount = activeCount;
        //print('PendingCount: $pendingCount, ActiveCount: $activeCount');
        _updateTotal();
      });
    } catch (e) {
      print('Error fetching delivery data: $e');
    }
  }

  void _fetchPreviousDeliveries() async {
    try {
      QuerySnapshot clientsSnapshot =
          await FirebaseFirestore.instance.collection('clients').get();

      int completedCount = 0;

      for (var clientDoc in clientsSnapshot.docs) {
        QuerySnapshot previousDeliveriesSnapshot = await FirebaseFirestore
            .instance
            .collection('clients')
            .doc(clientDoc.id)
            .collection('previousDeliveries')
            .get();

        for (var doc in previousDeliveriesSnapshot.docs) {
          String status = doc['status'];

          if (status == 'נמסר') {
            completedCount++;
          }
        }
      }

      setState(() {
        this.completedCount = completedCount;
        _updateTotal();
      });
    } catch (e) {
      print('Error fetching delivery data: $e');
    }
  }

  void _updateTotal() {
    // print('UpdateTotal called');
    setState(() {
      total = pendingCount + activeCount + completedCount;
      // print('Pending: $pendingCount, Active: $activeCount, Completed: $completedCount, Total: $total');
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
                automaticallyImplyLeading: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      _buildDeliveryOverviewSection(
                          screenHeight, widget.categories, context),
                      SizedBox(height: screenHeight * 0.02),
                      _buildTodaysDeliveriesSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOverviewSection(double screenHeight,
      List<Map<String, dynamic>> categories, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.03),
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(31, 4, 4, 4),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompletedOrdersPage(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.blue, size: screenHeight * 0.025),
                    SizedBox(width: screenHeight * 0.01),
                    Text(
                      "נמסר",
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
            value: total > 0
                ? completedCount / total
                : 0.0, // Dynamically calculate progress
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
            minHeight: screenHeight * 0.015,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "$completedCount / $total", // Completed deliveries count
            style: TextStyle(
              fontSize: screenHeight * 0.018,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Active and Pending Deliveries
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Active Deliveries Card
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveOrdersPage(),
                      ),
                    );
                  },
                  child: _buildActivePendingCard(
                    title: "בתהליך",
                    count: activeCount,
                    color: Colors.green,
                    icon: Icons.local_shipping,
                    screenHeight: screenHeight,
                  ),
                ),
              ),
              SizedBox(width: screenHeight * 0.02), // Space between the cards

              // Pending Deliveries Card
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PendingOrdersPage(),
                      ),
                    );
                  },
                  child: _buildActivePendingCard(
                    title: "חדשה",
                    count: pendingCount,
                    color: Colors.orange,
                    icon: Icons.new_releases,
                    screenHeight: screenHeight,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.03),
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
            Icon(icon, size: screenHeight * 0.025, color: color),
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

  Widget _buildTodaysDeliveriesSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTodaysDeliveries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final deliveries = snapshot.data ?? [];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "משלוחים להיום",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              //const SizedBox(height: 0.1),
              deliveries.isEmpty
                  ? const Center(
                      child: Text(
                        'אין משלוחים להיום.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: deliveries.length,
                      itemBuilder: (context, index) {
                        final delivery = deliveries[index];
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: const Color.fromARGB(255, 255, 255, 255),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Leading Icon
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Delivery Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        delivery['name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        delivery['clientAddress'] ??
                                            'No Address',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 130, 130, 130),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Status: ${delivery['status'] ?? 'No Status'}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}

class PendingOrdersPage extends StatelessWidget {
  const PendingOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הזמנות חדשות'),
        backgroundColor: const Color.fromARGB(255, 141, 126, 106),
      ),
      body: GestureDetector(
        onTap: () {
          // Unfocus the current focus node to dismiss the keyboard
          FocusScope.of(context).unfocus();
        },
        child: FutureBuilder(
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
                    .where('status', whereIn: [
                  'חדשה',
                  'באיחור'
                ]) // Check for multiple values
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
      ),
    );
  }
}

class ActiveOrdersPage extends StatelessWidget {
  const ActiveOrdersPage({super.key});

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
  const CompletedOrdersPage({super.key});

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
