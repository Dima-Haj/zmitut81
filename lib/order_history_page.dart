import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryPage extends StatelessWidget {
  final String customerName;
  final String clientId;
  final List<Map<String, dynamic>> orders;

  const OrderHistoryPage({
    super.key,
    required this.customerName,
    required this.clientId,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders History - $customerName'),
        backgroundColor: const Color.fromARGB(255, 131, 107, 81),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: screenHeight * 0.1),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              height: screenHeight * 0.24, // Adjust height as needed
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
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Order Details on the Right
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'שם קטגוריה: ${order['name']}',
                              style: GoogleFonts.exo2(
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              'תאריך הזמנה: ${order['Date']}',
                              style: GoogleFonts.exo2(
                                  fontSize: screenHeight * 0.016),
                            ),
                            SizedBox(height: screenHeight * 0.004),
                            Text(
                              'אריזה: ${order['isPackaged'] == true ? "כן" : "לא"}',
                              style: GoogleFonts.exo2(
                                  fontSize: screenHeight * 0.016),
                            ),
                            SizedBox(height: screenHeight * 0.004),
                            Text(
                              'שם מוצר: ${order['product']}',
                              style: GoogleFonts.exo2(
                                  fontSize: screenHeight * 0.016),
                            ),
                            if (order.containsKey('Sub-Product') &&
                                order['Sub-Product'] != '')
                              Text(
                                'שם תת-מוצר: ${order['Sub-Product']}',
                                style: GoogleFonts.exo2(
                                    fontSize: screenHeight * 0.016),
                              ),
                            if (!order['isPackaged'] &&
                                order.containsKey('packagingDetails'))
                              Text(
                                'פרטי הזמנה: ${order['packagingDetails']}',
                                style: GoogleFonts.exo2(
                                    fontSize: screenHeight * 0.016),
                              ),
                            Text(
                              'משקל: ${order['weight']} ${order['weightType']}',
                              style: GoogleFonts.exo2(
                                  fontSize: screenHeight * 0.016),
                            ),
                            if (order.containsKey('size'))
                              Text(
                                'גודל: ${order['size']}',
                                style: GoogleFonts.exo2(
                                    fontSize: screenHeight * 0.016),
                              ),
                            Text(
                              'סטטוס: ${order['status']}',
                              style: GoogleFonts.exo2(
                                  fontSize: screenHeight * 0.016),
                            ),
                          ],
                        ),
                      ),

                      // Buttons on the Left
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      // Handle Edit action
                                    },
                                    tooltip: 'ערוך הזמנה', // Tooltip in Hebrew
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      try {
                                        // Confirm deletion
                                        bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (context) => Directionality(
                                            textDirection: TextDirection
                                                .rtl, // Set RTL direction
                                            child: AlertDialog(
                                              title: const Text(
                                                'מחיקת הזמנה',
                                                textAlign: TextAlign
                                                    .right, // Align the title to the right
                                              ),
                                              content: const Text(
                                                'האם אתה בטוח שברצונך למחוק את ההזמנה?',
                                                textAlign: TextAlign
                                                    .right, // Align the content to the right
                                              ),
                                              actionsAlignment: MainAxisAlignment
                                                  .start, // Align actions to the right
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: const Text(
                                                    'ביטול',
                                                    textAlign: TextAlign
                                                        .center, // Center-align the text in the button
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text(
                                                    'מחיקה',
                                                    textAlign: TextAlign
                                                        .center, // Center-align the text in the button
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );

                                        if (!confirmDelete) {
                                          return; // If the user cancels, exit the function
                                        }

                                        // Delete the order from Firestore
                                        await FirebaseFirestore.instance
                                            .collection('clients')
                                            .doc(
                                                clientId) // Replace with the clientId from the previous page
                                            .collection('orders')
                                            .doc(order[
                                                'orderId']) // Replace with the orderId for this order
                                            .delete();

                                        // Remove the order from the local list
                                        orders.removeWhere((o) =>
                                            o['orderId'] == order['orderId']);

                                        // Refresh the UI
                                        (context as Element).markNeedsBuild();

                                        // Optionally, show a success message
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('הזמנה נמחקה בהצלחה.')),
                                        );
                                      } catch (e) {
                                        // Handle any errors
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'נכשל במחיקת ההזמנה: $e')),
                                        );
                                      }
                                    },
                                    tooltip: 'מחק הזמנה', // Tooltip in Hebrew
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }
}
