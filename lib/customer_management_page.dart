import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_history_page.dart';
import 'admin_dashboard_page.dart';

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
  int _selectedIndex = 1; // Default selected index for dashboard (middle)

  @override
  void initState() {
    super.initState();
    // Initialize the swipe state for each customer
    for (var customer in customers) {
      isSwiped[customer['name']!] = false;
    }
  }

  /*void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      // Navigate to Dashboard Management Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboardPageContent(),
        ),
      );
    } else if (index == 0) {
      // If index 0 is tapped, stay on the customer page or perform some logic
      // You don't need to navigate anywhere since you're already on CustomerManagementPage
    } else if (index == 2) {
      // Handle settings or other navigation logic for the Settings button
      // Add your settings page navigation here
    }
  }*/

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredCustomers = customers
        .where((customer) =>
            customer['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
                'assets/images/image1.png'), // Your background image path
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              const Color.fromARGB(255, 42, 42, 42).withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 60.0), // To move elements lower

              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Customers...',
                    hintStyle: GoogleFonts.exo2(
                      fontSize: 16.0, // Adjust font size as needed
                      color: const Color.fromARGB(
                          255, 213, 213, 213), // Set hint text color
                    ),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Customer list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    return Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Stack(
                        children: [
                          // Background with Edit/Delete buttons
                          Positioned.fill(
                            child: buildSwipeActionLeft(
                              onEdit: () {
                                setState(() {
                                  isSwiped[customer['name']!] = false;
                                });
                              },
                              onDelete: () {
                                setState(() {
                                  customers.removeAt(index);
                                  isSwiped.remove(customer['name']!);
                                });
                              },
                            ),
                          ),
                          // The actual customer box
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            left: isSwiped[customer['name']!] == true
                                ? -130.0
                                : 0.0,
                            right: isSwiped[customer['name']!] == true
                                ? 130.0
                                : 0.0,
                            child: GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                if (details.primaryDelta != null &&
                                    details.primaryDelta! < -20) {
                                  setState(() {
                                    isSwiped[customer['name']!] = true;
                                  });
                                } else if (details.primaryDelta != null &&
                                    details.primaryDelta! > 20) {
                                  setState(() {
                                    isSwiped[customer['name']!] = false;
                                  });
                                }
                              },
                              child: CustomerBox(
                                name: customer['name']!,
                                phone: customer['phone']!,
                                email: customer['email']!,
                                onViewOrders: () {
                                  // Example order history data
                                  final orders = [
                                    {
                                      'orderID': '001',
                                      'orderDate': '2023-10-01',
                                      'orderTotal': '\$50.00',
                                      'orderStatus': 'Pending',
                                    },
                                    {
                                      'orderID': '002',
                                      'orderDate': '2023-10-05',
                                      'orderTotal': '\$75.00',
                                      'orderStatus': 'Pending',
                                    },
                                    {
                                      'orderID': '003',
                                      'orderDate': '2023-10-10',
                                      'orderTotal': '\$100.00',
                                      'orderStatus': 'Pending',
                                    },
                                  ];

                                  // Navigate to the OrderHistoryPage
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating action button to add a customer
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          onPressed: () {
            _showAddCustomerDialog(context);
          },
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          foregroundColor: const Color.fromARGB(255, 131, 107, 81),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Color.fromARGB(255, 131, 107, 81), // Border color
              width: 3.0, // Border width
            ),
            borderRadius: BorderRadius.circular(30.0), // Make it circular
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Background widget for swipe action with clickable buttons
  Widget buildSwipeActionLeft(
      {required VoidCallback onEdit, required VoidCallback onDelete}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(
            255, 141, 126, 106), // Background color when swiping
        borderRadius:
            BorderRadius.circular(28.0), // Rounded corners with 28 pixel radius
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.edit,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: onEdit,
          ),
          IconButton(
            icon:
                const Icon(Icons.delete, color: Color.fromARGB(255, 255, 0, 0)),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
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
  final String name;
  final String phone;
  final String email;
  final VoidCallback onViewOrders;

  const CustomerBox({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.onViewOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 141, 126, 106),
          width: 1.0,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(phone, style: GoogleFonts.exo2()),
                const SizedBox(height: 4.0),
                Text(email, style: GoogleFonts.exo2()),
              ],
            ),
          ),

          // Middle: View Order History Button
          Expanded(
            flex: 2,
            child: Align(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 12.0), // Adjust the top padding to move it lower
                child: ElevatedButton(
                  onPressed: onViewOrders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 131, 107, 81),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Orders History',
                    style: GoogleFonts.exo2(
                      color: Colors.white,
                      fontSize: 11.0,
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
