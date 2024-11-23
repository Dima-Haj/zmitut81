import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_history_page.dart';

class CustomerManagementPage extends StatefulWidget {
  const CustomerManagementPage({super.key});

  @override
  _CustomerManagementPageState createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  final List<Map<String, String>> customers = [
    {
      'name': 'John Doe',
      'phone': '+1 555-123-4567',
      'email': 'johndoe@example.com'
    },
    {
      'name': 'Jane Smith',
      'phone': '+1 555-987-6543',
      'email': 'janesmith@example.com'
    },
    {
      'name': 'Alice Johnson',
      'phone': '+1 555-111-2222',
      'email': 'alicejohnson@example.com'
    },
  ];

  String searchQuery = "";
  Map<String, bool> isSwiped = {}; // To track which items are swiped left

  @override
  void initState() {
    super.initState();
    for (var customer in customers) {
      isSwiped[customer['name']!] = false;
    }
  }

@override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  final filteredCustomers = customers
      .where((customer) =>
          customer['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  return Scaffold(
    body: Container(
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.1),

            // Search Field
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Customers...',
                hintStyle: GoogleFonts.exo2(
                  fontSize: screenHeight * 0.018,
                  color: const Color.fromARGB(255, 213, 213, 213),
                ),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.02),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Customer List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: screenHeight * 0.1),
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  return Container(
                    height: screenHeight * 0.13,
                    margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenHeight * 0.02),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: screenHeight * 0.01,
                          spreadRadius: screenHeight * 0.005,
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenHeight * 0.01),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  customer['name']!,
                                  style: GoogleFonts.exo2(
                                    fontSize: screenHeight * 0.02,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  customer['phone']!,
                                  style: GoogleFonts.exo2(
                                    fontSize: screenHeight * 0.016,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  customer['email']!,
                                  style: GoogleFonts.exo2(
                                    fontSize: screenHeight * 0.016,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  final orders = [
                                    {
                                      'orderID': '001',
                                      'orderDate': '2023-10-01',
                                      'orderTotal': '\$50.00',
                                      'orderStatus': 'Pending',
                                    },
                                  ];

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderHistoryPage(
                                        customerName: customer['name']!,
                                        orders: orders,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255, 131, 107, 81),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(screenHeight * 0.02),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.005,
                                    horizontal: screenWidth * 0.002,
                                  ),
                                  child: Text(
                                    'Orders History',
                                    style: GoogleFonts.exo2(
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.015,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),

    // Floating Action Button
    floatingActionButton: Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
      child: FloatingActionButton(
        onPressed: () {
          _showAddCustomerDialog(context);
        },
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: const Color.fromARGB(255, 131, 107, 81),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color.fromARGB(255, 131, 107, 81),
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: const Icon(Icons.add),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  );
}


  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add Customer',
            style: TextStyle(fontSize: screenHeight * 0.025),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(fontSize: screenHeight * 0.02),
                ),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(fontSize: screenHeight * 0.02),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: screenHeight * 0.02),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Add',
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              onPressed: () {
                setState(() {
                  customers.add({
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'email': emailController.text,
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Widget for a single customer box
class CustomerBox extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final String name;
  final String phone;
  final String email;
  final VoidCallback onViewOrders;

  const CustomerBox({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.name,
    required this.phone,
    required this.email,
    required this.onViewOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.015),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 141, 126, 106),
          width: screenWidth * 0.003,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            spreadRadius: 5.0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: GoogleFonts.exo2(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(phone, style: GoogleFonts.exo2(fontSize: screenHeight * 0.02)),
                SizedBox(height: screenHeight * 0.005),
                Text(email, style: GoogleFonts.exo2(fontSize: screenHeight * 0.02)),
              ],
            ),
          ),
Expanded(
  flex: 2,
  child: Align(
    child: Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.01), // Adjust top padding for alignment
      child: ElevatedButton(
        onPressed: onViewOrders,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 131, 107, 81),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenHeight * 0.015), // Smaller corners
          ),
        ),
        child: Text(
          'Orders History',
          style: GoogleFonts.exo2(
            color: Colors.white,
            fontSize: screenHeight * 0.013, // Reduce font size
          ),
        ),
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}
