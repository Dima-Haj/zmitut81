import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_history_page.dart';
import 'add_customer_page.dart';

class CustomerManagementPage extends StatefulWidget {
  final Map<String, dynamic>? managerDetails; // Optional manager details

  const CustomerManagementPage({super.key, this.managerDetails});

  @override
  _CustomerManagementPageState createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  @override
  void initState() {
    super.initState();
    fetchClientsWithOrders(); // Fetch data when the widget initializes
  }

  final List<Map<String, dynamic>> customers = [];
  Future<void> fetchClientsWithOrders() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get all clients
      final clientsSnapshot = await firestore.collection('clients').get();

      List<Map<String, dynamic>> fetchedCustomers = [];

      for (var clientDoc in clientsSnapshot.docs) {
        final clientData = clientDoc.data();
        final clientId = clientDoc.id;

        // Get orders for the client
        final ordersSnapshot = await firestore
            .collection('clients')
            .doc(clientId)
            .collection('orders')
            .get();

        List<Map<String, dynamic>> orders = ordersSnapshot.docs.map((orderDoc) {
          return orderDoc.data();
        }).toList();

        // Combine client data with their orders
        fetchedCustomers.add({
          'name': clientData['name'] ?? '',
          'phone': clientData['phone'] ?? '',
          'email': clientData['email'] ?? '',
          'address': clientData['address'] ?? '',
          'products': orders,
        });
      }

      // Update state with fetched data
      setState(() {
        customers.clear();
        customers.addAll(fetchedCustomers);
      });
    } catch (e) {
      print('Error fetching clients: $e');
      // Show an error message or handle appropriately
    }
  }

  String searchQuery = "";

  List<Map<String, dynamic>> _getFilteredCustomers() {
    return customers.where((customer) {
      return customer['name']!
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredCustomers = _getFilteredCustomers();

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
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  onChanged: (value) {
                    if (searchQuery != value) {
                      setState(() {
                        searchQuery = value;
                      });
                    }
                  },
                  textAlign: TextAlign.right, // Align text to the right
                  decoration: InputDecoration(
                    hintText: 'חפש לקוח לפי שם',
                    hintStyle: GoogleFonts.exo2(
                      fontSize: screenHeight * 0.018,
                      color: const Color.fromARGB(255, 213, 213, 213),
                    ),
                    prefixIcon: const Icon(
                        Icons.search), // Search icon stays on the left
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.02),
                    ),
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
                      height: screenHeight * 0.14,
                      margin:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.02),
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
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Labels on the right
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
                                    SizedBox(height: screenHeight * 0.004),
                                    Text(
                                      customer['email']!,
                                      style: GoogleFonts.exo2(
                                        fontSize: screenHeight * 0.016,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.004),
                                    Text(
                                      customer['address']!,
                                      style: GoogleFonts.exo2(
                                        fontSize: screenHeight * 0.016,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Button on the left
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderHistoryPage(
                                            customerName: customer['name']!,
                                            orders: (customer['products']
                                                    as List<
                                                        Map<String,
                                                            dynamic>>?) ??
                                                [], // Ensure orders is a valid list
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 131, 107, 81),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            screenHeight * 0.02),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.005,
                                        horizontal: screenWidth * 0.002,
                                      ),
                                      child: Text(
                                        'צפיה בהזמנות',
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
          heroTag: 'customerManagementButton', // Add a unique tag here
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddCustomerPage(
                  onAddCustomer: (newCustomer) {
                    setState(() {
                      customers.add(newCustomer);
                    });
                  },
                ),
              ),
            );
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
}
