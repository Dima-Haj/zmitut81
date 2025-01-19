import 'package:flutter/material.dart';
import 'package:flutter_application_1/Admin_pages/user_requests_page.dart';
import 'customer_management_page.dart';
import 'employee_management_page.dart';
import 'admin_dashboard_page.dart';
import '../Home_pages/login_page.dart';

class AdminHomePage extends StatefulWidget {
  final Map<String, dynamic> managerDetails;

  const AdminHomePage({super.key, required this.managerDetails});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;
  late String firstName;
  late String email;

  @override
  void initState() {
    super.initState();

    firstName = widget.managerDetails['firstName'] ?? 'Manager';
    email = widget.managerDetails['email'] ?? 'Unknown Email';

    _pages = [
      const CustomerManagementPage(),
      AdminDashboardPage(
        managerDetails: widget.managerDetails,
        categories: [],
      ),
      const EmployeeManagementPage(),
      UserRequestsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPageWithLogout(Widget page) {
    return Stack(
      children: [
        page,
        Positioned(
          top: 48, // Adjust the position of the button as needed
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Unfocus the current focus node to dismiss the keyboard
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Container(
              height: screenHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/image1.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Hello, $firstName!',
                  style: TextStyle(
                    fontSize: screenHeight * 0.03,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: _buildPageWithLogout(_pages.elementAt(_selectedIndex)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensure fixed behavior

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'לקוחות', // Customers
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'משלוחים',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'עובדים', // Employees
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'בקשות', // Requests
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}
