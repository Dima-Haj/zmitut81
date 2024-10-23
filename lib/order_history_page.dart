import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryPage extends StatelessWidget {
  final String customerName;
  final List<Map<String, String>> orders;

  const OrderHistoryPage({
    super.key,
    required this.customerName,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders History - $customerName'),
        backgroundColor: const Color.fromARGB(255, 131, 107, 81),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text(
              'Order ID: ${order['orderID']}',
              style: GoogleFonts.exo2(),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${order['orderDate']}', style: GoogleFonts.exo2()),
                Text('Total: ${order['orderTotal']}',
                    style: GoogleFonts.exo2()),
                Text('Status: ${order['orderStatus']}',
                    style: GoogleFonts.exo2()),
              ],
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
