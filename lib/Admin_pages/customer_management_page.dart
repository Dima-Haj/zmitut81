import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Designed_helper_fields/custom_text_field.dart';
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
          'clientId': clientData['clientId'] ?? '',
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
                          EdgeInsets.symmetric(vertical: screenHeight * 0.005),
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
                        padding: EdgeInsets.all(screenHeight * 0.005),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
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
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .end, // Align all icons to the right
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility,
                                            color: Colors.blue), // Eye icon
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderHistoryPage(
                                                customerName: customer['name']!,
                                                clientId: customer['clientId'],
                                                orders: (customer['products']
                                                        as List<
                                                            Map<String,
                                                                dynamic>>?) ??
                                                    [],
                                              ),
                                            ),
                                          );
                                        },
                                        tooltip: 'צפיה בהזמנות',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.orange), // Edit icon
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled:
                                                true, // Allow the panel to take up needed space
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(20)),
                                            ),
                                            builder: (BuildContext context) {
                                              // Responsive screen sizing

                                              // Split name into first name and last name
                                              List<String> nameParts =
                                                  (customer['name'] ?? '')
                                                      .split(' ');
                                              final TextEditingController
                                                  firstNameController =
                                                  TextEditingController(
                                                      text: nameParts.isNotEmpty
                                                          ? nameParts[0]
                                                          : '');
                                              final TextEditingController
                                                  lastNameController =
                                                  TextEditingController(
                                                      text: nameParts.length > 1
                                                          ? nameParts
                                                              .sublist(1)
                                                              .join(' ')
                                                          : '');
                                              final TextEditingController
                                                  phoneController =
                                                  TextEditingController(
                                                      text: customer['phone']);
                                              final TextEditingController
                                                  emailController =
                                                  TextEditingController(
                                                      text: customer['email']);
                                              final TextEditingController
                                                  addressController =
                                                  TextEditingController(
                                                      text:
                                                          customer['address']);

                                              return Padding(
                                                  padding: EdgeInsets.only(
                                                    left: screenWidth * 0.04,
                                                    right: screenWidth * 0.04,
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom,
                                                    top: screenHeight * 0.02,
                                                  ),
                                                  child: Directionality(
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // Header Title
                                                        Text(
                                                          'עריכת פרטי לקוח',
                                                          style: TextStyle(
                                                            fontSize:
                                                                screenHeight *
                                                                    0.025,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        CustomTextField(
                                                          hintText: 'שם פרטי',
                                                          icon: Icons.person,
                                                          controller:
                                                              firstNameController,
                                                          screenWidth:
                                                              screenWidth,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text, // Text input
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.01),

                                                        // Last Name Field
                                                        CustomTextField(
                                                          hintText: 'שם משפחה',
                                                          icon: Icons
                                                              .person_outline,
                                                          controller:
                                                              lastNameController,
                                                          screenWidth:
                                                              screenWidth,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text, // Text input
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.01),

                                                        // Phone Number Field
                                                        CustomTextField(
                                                          hintText:
                                                              'מספר טלפון',
                                                          icon: Icons.phone,
                                                          controller:
                                                              phoneController,
                                                          screenWidth:
                                                              screenWidth,
                                                          keyboardType:
                                                              TextInputType
                                                                  .phone, // Numeric phone input
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.01),

                                                        // Email Field
                                                        CustomTextField(
                                                          hintText: 'אימייל',
                                                          icon: Icons.email,
                                                          controller:
                                                              emailController,
                                                          screenWidth:
                                                              screenWidth,
                                                          keyboardType:
                                                              TextInputType
                                                                  .emailAddress, // Email input
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.01),

                                                        // Address Field
                                                        CustomTextField(
                                                          hintText: 'כתובת',
                                                          icon:
                                                              Icons.location_on,
                                                          controller:
                                                              addressController,
                                                          screenWidth:
                                                              screenWidth,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text, // Text input
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.02),

                                                        // Action Buttons: Cancel and Save
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            // Cancel Button
                                                            ElevatedButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  vertical:
                                                                      screenHeight *
                                                                          0.015,
                                                                  horizontal:
                                                                      screenWidth *
                                                                          0.05,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                'ביטול',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        screenHeight *
                                                                            0.02),
                                                              ),
                                                            ),

                                                            // Save Button
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                try {
                                                                  // Combine first and last name
                                                                  final updatedName =
                                                                      '${firstNameController.text} ${lastNameController.text}'
                                                                          .trim();

                                                                  // Update the Firestore database
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'clients')
                                                                      .doc(customer[
                                                                          'clientId'])
                                                                      .update({
                                                                    'name':
                                                                        updatedName,
                                                                    'phone':
                                                                        phoneController
                                                                            .text,
                                                                    'email':
                                                                        emailController
                                                                            .text,
                                                                    'address':
                                                                        addressController
                                                                            .text,
                                                                  });

                                                                  // Optionally refresh the parent page or local state
                                                                  setState(() {
                                                                    customer[
                                                                            'name'] =
                                                                        updatedName;
                                                                    customer[
                                                                            'phone'] =
                                                                        phoneController
                                                                            .text;
                                                                    customer[
                                                                            'email'] =
                                                                        emailController
                                                                            .text;
                                                                    customer[
                                                                            'address'] =
                                                                        addressController
                                                                            .text;
                                                                  });

                                                                  // Close the edit panel
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  // Show success message
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                        content:
                                                                            Text('פרטי הלקוח עודכנו בהצלחה')),
                                                                  );
                                                                } catch (e) {
                                                                  // Handle error
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text('שגיאה בעדכון פרטי הלקוח: $e')),
                                                                  );
                                                                }
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .orange,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  vertical:
                                                                      screenHeight *
                                                                          0.015,
                                                                  horizontal:
                                                                      screenWidth *
                                                                          0.05,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                'ערוך',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        screenHeight *
                                                                            0.02),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ));
                                            },
                                          );
                                        },
                                        tooltip: 'עריכת לקוח',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red), // Delete icon
                                        onPressed: () async {
                                          try {
                                            // Confirm deletion
                                            bool confirmDelete =
                                                await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  Directionality(
                                                textDirection:
                                                    TextDirection.rtl,
                                                child: AlertDialog(
                                                  title:
                                                      const Text('מחיקת לקוח'),
                                                  content: const Text(
                                                    'האם אתה בטוח שברצונך למחוק את הלקוח?',
                                                    textAlign: TextAlign.right,
                                                  ),
                                                  actionsAlignment:
                                                      MainAxisAlignment.start,
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child:
                                                          const Text('ביטול'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                      child:
                                                          const Text('מחיקה'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );

                                            if (confirmDelete) {
                                              // Perform deletion from Firestore
                                              await FirebaseFirestore.instance
                                                  .collection('clients')
                                                  .doc(customer['clientId'])
                                                  .delete();

                                              // Remove the customer locally
                                              setState(() {
                                                customers.removeWhere((c) =>
                                                    c['clientId'] ==
                                                    customer['clientId']);
                                              });

                                              // Optionally show a success message
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'הלקוח נמחק בהצלחה')),
                                              );
                                            }
                                          } catch (e) {
                                            // Handle errors
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'שגיאה במחיקת הלקוח: $e')),
                                            );
                                          }
                                        },
                                        tooltip: 'מחיקת לקוח',
                                      ),
                                    ],
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
                    // This is where you handle the new customer addition if needed
                  },
                ),
              ),
            ).then((result) {
              if (result == true) {
                // Re-fetch the data since the result indicates the data changed
                fetchClientsWithOrders();
              }
            });
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
