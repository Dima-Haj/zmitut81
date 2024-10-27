import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart'; // for launching URLs
import 'customer_management_page.dart'; // Import CustomerManagementPage

void main() => runApp(const AdminDashboardApp());

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AdminDashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
        leading: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'Notifications':
                break;
              case 'Drivers Information':
                break;
              case 'Delivery Reports':
                break;
              // Add more cases as needed
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(
                value: 'Notifications',
                child: Text('Notifications History'),
              ),
              const PopupMenuItem(
                value: 'Drivers Information',
                child: Text('Drivers Information'),
              ),
              const PopupMenuItem(
                value: 'Delivery Reports',
                child: Text('Delivery Reports'),
              ),
              const PopupMenuItem(
                value: 'Settings',
                child: Text('Settings'),
              ),
            ];
          },
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Delivery Overview
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Delivery Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            DeliveryOverviewWidget(),
            // Performance Metrics
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Performance Metrics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            PerformanceMetricsWidget(),
            // Map with clickable icon
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Live Map',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            MapWidget(),
          ],
        ),
      ),
    );
  }
}

// Make _launchURL a global method
Future<void> _launchURL(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw 'Could not launch $url';
  }
}

class DeliveryOverviewWidget extends StatelessWidget {
  const DeliveryOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DeliveryStatusCard(
            status: "Active",
            icon: Icons.local_shipping,
            count: 12,
            iconColor: Colors.green, // Random number for Active
          ),
          DeliveryStatusCard(
            status: "Pending",
            icon: Icons.access_time,
            count: 5,
            iconColor: Colors.orange, // Random number for Pending
          ),
          DeliveryStatusCard(
            status: "Completed",
            icon: Icons.check_circle,
            count: 24,
            iconColor: Colors.blue, // Random number for Completed
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
  final Color iconColor;

  const DeliveryStatusCard({
    super.key,
    required this.status,
    required this.icon,
    required this.count,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to CustomerManagementPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerManagementPage(),
          ),
        );
      },
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(status),
        ],
      ),
    );
  }
}

class PerformanceMetricsWidget extends StatelessWidget {
  const PerformanceMetricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Column(
        children: <Widget>[
          // First Row (Delay Rate and On-Time Rate)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MetricCard(title: "Delay Rate", value: "30%"),
              MetricCard(title: "On-time Rate", value: "90%"),
            ],
          ),
          SizedBox(height: 10),
          // Second Row (Success Rate and Avg Cost per Delivery)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
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
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(35.217018, 31.771959),
              initialZoom: 13.0,
            ),
            children: [
              // Tile Layer for OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              // Rich Attribution
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => _launchURL('https://openstreetmap.org/copyright'),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FullScreenMap()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenMap extends StatelessWidget {
  const FullScreenMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full Screen Map')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(35.217018, 31.771959),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => _launchURL('https://openstreetmap.org/copyright'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
