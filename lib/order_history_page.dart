import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryPage extends StatelessWidget {
  final String customerName;
  final List<Map<String, dynamic>> orders;

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
              'שם קטגוריה: ${order['name']}',
              style: GoogleFonts.exo2(),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('תאריך הזמנה: ${order['Date']}',
                    style: GoogleFonts.exo2()),
                Text(
                    'נשמר בשקיות: ${order['isPackaged'] == true ? "כן" : "לא"}',
                    style: GoogleFonts.exo2()),
                Text('שם מוצר: ${order['product']}', style: GoogleFonts.exo2()),
                if (order.containsKey('Sub-Product') &&
                    order['Sub-Product'] != '')
                  Text('פרטי הזמנה: ${order['packagingDetails']}',
                      style: GoogleFonts.exo2()),
                Text('שם תת-מוצר: ${order['Sub-Product']}',
                    style: GoogleFonts.exo2()),
                Text('משקל: ${order['weight']} ${order['weightType']}',
                    style: GoogleFonts.exo2()),
                if (order.containsKey('size'))
                  Text('גודל: ${order['size']}', style: GoogleFonts.exo2()),
              ],
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
