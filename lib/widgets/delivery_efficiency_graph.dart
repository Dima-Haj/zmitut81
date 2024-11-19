// This is your DeliveryEfficiencyGraph widget file (delivery_efficiency_graph.dart)
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/delivery.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/admin_dashboard_page.dart';

class DeliveryEfficiencyGraph extends StatelessWidget {
  final List<Delivery> deliveries;

  const DeliveryEfficiencyGraph({super.key, required this.deliveries});

  @override
  Widget build(BuildContext context) {
    // Prepare data points for the graph
    List<FlSpot> dataPoints = [];
    for (int i = 0; i < deliveries.length; i++) {
      // Convert delivery times into hours for simplicity (you can customize this)
      double scheduled = deliveries[i].scheduledTime.hour.toDouble();
      double actual = deliveries[i].actualTime.hour.toDouble();
      dataPoints.add(FlSpot(scheduled, actual));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints,
            isCurved: true,
            barWidth: 3,
            colors: [Colors.blue],
            belowBarData:
                BarAreaData(show: true, colors: [Colors.blue.withOpacity(0.3)]),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitles: (value) => 'Scheduled ${value.toInt()}',
            getTextStyles: (context, value) => const TextStyle(fontSize: 12),
          ),
          leftTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitles: (value) => 'Actual ${value.toInt()}',
            getTextStyles: (context, value) => const TextStyle(fontSize: 12),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black12, width: 1),
        ),
      ),
    );
  }
}
