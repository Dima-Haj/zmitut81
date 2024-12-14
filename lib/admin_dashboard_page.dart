import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardPage extends StatelessWidget {
  final Map<String, dynamic> managerDetails;

  const AdminDashboardPage({super.key, required this.managerDetails});

  @override
  Widget build(BuildContext context) {
    final String firstName = managerDetails['firstName'] ?? 'Manager';
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, $firstName',
          style: GoogleFonts.exo2(
            fontSize: screenHeight * 0.03,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 141, 126, 106),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(title: 'Delivery Overview'),
            const SizedBox(height: 16),
            DeliveryOverviewWidget(screenHeight: screenHeight),
            const SizedBox(height: 16),
            PageTitle(title: 'Performance Metrics'),
            const SizedBox(height: 16),
            PerformanceMetricsWidget(screenHeight: screenHeight),
          ],
        ),
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  final String title;

  const PageTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.exo2(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class DeliveryOverviewWidget extends StatelessWidget {
  final double screenHeight;

  const DeliveryOverviewWidget({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DeliveryStatusCard(
            status: "Active",
            icon: Icons.local_shipping,
            count: 12,
            iconSize: screenHeight * 0.04,
          ),
          DeliveryStatusCard(
            status: "Pending",
            icon: Icons.access_time,
            count: 5,
            iconSize: screenHeight * 0.04,
          ),
          DeliveryStatusCard(
            status: "Completed",
            icon: Icons.check_circle,
            count: 30,
            iconSize: screenHeight * 0.04,
          ),
        ],
      ),
    );
  }
}

class DeliveryStatusCard extends StatelessWidget {
  final String status;
  final IconData icon;
  final int count;
  final double iconSize;

  const DeliveryStatusCard({
    super.key,
    required this.status,
    required this.icon,
    required this.count,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: iconSize, color: const Color.fromARGB(255, 141, 126, 106)),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(fontSize: iconSize, fontWeight: FontWeight.bold),
        ),
        Text(status, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class PerformanceMetricsWidget extends StatelessWidget {
  final double screenHeight;

  const PerformanceMetricsWidget({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              MetricCard(title: "Delay Rate", value: "30%"),
              MetricCard(title: "On-time Rate", value: "90%"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              MetricCard(title: "Return Rate", value: "20%"),
              MetricCard(title: "Avg Cost/Delivery", value: "\$250"),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const MetricCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
