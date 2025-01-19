import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Designed_helper_fields/custom_text_field.dart';
import 'package:flutter_application_1/Designed_helper_fields/date_of_birth_dropdowns.dart';
import 'package:flutter_application_1/Designed_helper_fields/dropdown_helpers.dart';
import 'package:flutter_application_1/Designed_helper_fields/phone_field.dart';

class UserRequestsPage extends StatefulWidget {
  @override
  _UserRequestsPageState createState() => _UserRequestsPageState();
}

class _UserRequestsPageState extends State<UserRequestsPage> {
  late Stream<QuerySnapshot> _waitingManagersStream;
  late Stream<QuerySnapshot> _waitingEmployeesStream;
  String selectedCategory = 'Managers'; // Default to show manager requests
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _waitingManagersStream =
        FirebaseFirestore.instance.collection('WaitingManagers').snapshots();
    _waitingEmployeesStream =
        FirebaseFirestore.instance.collection('WaitingEmployees').snapshots();
  }

  Future<void> _acceptUser(
      String collection, String docId, Map<String, dynamic> data) async {
    try {
      final targetCollection =
          collection == 'WaitingManagers' ? 'Managers' : 'Employees';
      await FirebaseFirestore.instance
          .collection(targetCollection)
          .doc(docId)
          .set(data);
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User accepted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept user: $e')),
      );
    }
  }

  Future<void> _declineUser(String collection, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User declined successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline user: $e')),
      );
    }
  }

  Widget _buildRequestList(
      String title, Stream<QuerySnapshot> stream, String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return Center(
            child: Text(
              'לא נמצאו בקשות $title',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final data = requests[index].data() as Map<String, dynamic>;
            final docId = requests[index].id;

            return Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Card(
                  color: Colors.white.withOpacity(0.8),
                  child: ListTile(
                    title: Text('${data['firstName']} ${data['lastName']}'),
                    subtitle: Text('Email: ${data['email']}'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _showUserDetailsDialog(data, collection, docId);
                      },
                      child: const Text('צפיה בבקשה'),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserDetailsDialog(
      Map<String, dynamic> userData, String collection, String docId) {
    final TextEditingController firstNameController =
        TextEditingController(text: userData['firstName']);
    final TextEditingController lastNameController =
        TextEditingController(text: userData['lastName']);
    final TextEditingController emailController =
        TextEditingController(text: userData['email']);
    final TextEditingController idController =
        TextEditingController(text: userData['id'] ?? '');
    final TextEditingController hourlyRateController =
        TextEditingController(text: userData['hourlyRate']?.toString() ?? '');
    final fullPhoneNumber = userData['phone'] ?? '';
    final String firstPart = fullPhoneNumber.substring(2, 3);
    final String secondPart = fullPhoneNumber.substring(3);
    final TextEditingController firstPartPhoneController =
        TextEditingController(text: firstPart);
    final TextEditingController secondPartPhoneController =
        TextEditingController(text: secondPart);
    String? selectedBirthDay = userData['birthDay'];
    String? selectedBirthMonth = userData['birthMonth'];
    String? selectedBirthYear = userData['birthYear'];
    String? selectedTruckSize = userData['truckSize'];
    String? selectedTruckType = userData['truckType'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            collection == "WaitingEmployees"
                                ? 'פרטי שליח'
                                : 'פרטי מנהל',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'שם פרטי',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 131, 107, 81),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.001),
                              CustomTextField(
                                hintText: 'הזן שם פרטי',
                                icon: Icons.person,
                                controller: firstNameController,
                                screenWidth: MediaQuery.of(context).size.width,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'שם משפחה',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 131, 107, 81),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.001),
                              CustomTextField(
                                hintText: 'הזן שם משפחה',
                                icon: Icons.person_outline,
                                controller: lastNameController,
                                screenWidth: MediaQuery.of(context).size.width,
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ת.ז',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 131, 107, 81),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.001),
                              CustomTextField(
                                hintText: 'הזן ת.ז כאן',
                                icon: Icons.badge,
                                controller: idController,
                                screenWidth: MediaQuery.of(context).size.width,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'מספר טלפון',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 131, 107, 81),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.001),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: PhoneField(
                                  firstPartController: firstPartPhoneController,
                                  secondPartController:
                                      secondPartPhoneController,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'אימייל',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 131, 107, 81),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.001),
                              CustomTextField(
                                hintText: 'הזן אימייל',
                                icon: Icons.email,
                                controller: emailController,
                                screenWidth: MediaQuery.of(context).size.width,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          Align(
                            alignment: Alignment.centerRight,
                            child: const Text(
                              'תאריך לידה',
                              style: TextStyle(
                                color: Color.fromARGB(255, 131, 107, 81),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          DateOfBirthDropdowns(
                            selectedDay: selectedBirthDay,
                            selectedMonth: selectedBirthMonth,
                            selectedYear: selectedBirthYear,
                            onDayChanged: (value) {
                              setDialogState(() {
                                selectedBirthDay = value;
                              });
                            },
                            onMonthChanged: (value) {
                              setDialogState(() {
                                selectedBirthMonth = value;
                              });
                            },
                            onYearChanged: (value) {
                              setDialogState(() {
                                selectedBirthYear = value;
                              });
                            },
                            screenWidth: MediaQuery.of(context).size.width,
                          ),
                          if (collection != "WaitingManagers") ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'סוג משאית',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 131, 107, 81),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                dropdownFieldFromList(
                                  label: '',
                                  items: ['פלטה', 'צובר', 'תפזורת'],
                                  currentValue: selectedTruckType,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedTruckType = value;
                                    });
                                  },
                                  screenWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                              ],
                            ),
                          ],
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'שכר לשעה',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 131, 107, 81),
                                  fontSize: 14,
                                ),
                              ),
                              CustomTextField(
                                hintText: 'הזן שכר לשעה',
                                icon: Icons.money,
                                controller: hourlyRateController,
                                screenWidth: MediaQuery.of(context).size.width,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align buttons to the right
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0), // Spacing between buttons
                      child: ElevatedButton(
                        onPressed: () async {
                          final updatedData = {
                            'firstName': firstNameController.text,
                            'lastName': lastNameController.text,
                            'email': emailController.text,
                            'phone': '05' +
                                firstPartPhoneController.text +
                                secondPartPhoneController.text,
                            'id': idController.text,
                            'birthDay': selectedBirthDay ?? '',
                            'birthMonth': selectedBirthMonth ?? '',
                            'birthYear': selectedBirthYear ?? '',
                            if (collection == "WaitingEmployees") ...{
                              'truckType': selectedTruckType ?? '',
                              if (selectedTruckType != 'צובר')
                                'truckSize': selectedTruckSize ?? '',
                            },
                            'hourlyRate': hourlyRateController.text,
                          };

                          try {
                            await FirebaseFirestore.instance
                                .collection(collection)
                                .doc(docId)
                                .update(updatedData);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('הפרטים עודכנו בהצלחה')),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('שגיאה בעדכון הפרטים: $e')),
                            );
                          }
                        },
                        child: const Text('שמור'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0), // Spacing between buttons
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // Green button for adding the user
                        ),
                        onPressed: () async {
                          // Perform validation checks
                          final isEmailValid = RegExp(
                                  r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                              .hasMatch(emailController.text);
                          final isFirstNameValid = RegExp(r"^[a-zA-Zא-ת\s]+$")
                              .hasMatch(firstNameController.text);
                          final isLastNameValid = RegExp(r"^[a-zA-Zא-ת\s]+$")
                              .hasMatch(lastNameController.text);
                          final isPhoneValid =
                              firstPartPhoneController.text.length == 1 &&
                                  secondPartPhoneController.text.length == 7;
                          final isIdValid = idController.text.length == 9;
                          final isBirthDateValid = selectedBirthDay != null &&
                              selectedBirthMonth != null &&
                              selectedBirthYear != null;

                          final hourlyRate =
                              double.tryParse(hourlyRateController.text);
                          final isHourlyRateValid =
                              hourlyRate != null && hourlyRate >= 32;

                          if (!isEmailValid ||
                              !isFirstNameValid ||
                              !isLastNameValid ||
                              !isPhoneValid ||
                              !isIdValid ||
                              !isBirthDateValid ||
                              !isHourlyRateValid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('חלק מהשדות אינם תקינים')),
                            );
                            return;
                          }

                          try {
                            await _acceptUser(collection, docId, {
                              'firstName': firstNameController.text,
                              'lastName': lastNameController.text,
                              'email': emailController.text,
                              'phone': '05' +
                                  firstPartPhoneController.text +
                                  secondPartPhoneController.text,
                              'id': idController.text,
                              'birthDay': selectedBirthDay ?? '',
                              'birthMonth': selectedBirthMonth ?? '',
                              'birthYear': selectedBirthYear ?? '',
                              if (collection == "WaitingEmployees") ...{
                                'truckType': selectedTruckType ?? '',
                                if (selectedTruckType != 'צובר')
                                  'truckSize': selectedTruckSize ?? '',
                              },
                              'hourlyRate': hourlyRateController.text,
                            });
                            Navigator.pop(
                                context); // Close dialog after adding the user
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('שגיאה בהוספת המשתמש: $e')),
                            );
                          }
                        },
                        child: const Text('הוסף'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0), // Spacing between buttons
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Red button for deleting the user
                        ),
                        onPressed: () async {
                          try {
                            await _declineUser(collection, docId);
                            Navigator.pop(
                                context); // Close dialog after deletion
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('שגיאה במחיקת המשתמש: $e')),
                            );
                          }
                        },
                        child: const Text('מחק'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      selectedCategory = index == 0 ? 'Managers' : 'Employees';
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      _pageController.animateToPage(
        category == 'Managers' ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
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
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.12),
            Text(
              'בקשות משתמשים חדשים',
              style: TextStyle(
                fontSize: screenHeight * 0.03,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _onCategorySelected('Managers'),
                  child: Column(
                    children: [
                      Text(
                        'מנהל', // Manager
                        style: TextStyle(
                          fontSize: 18,
                          color: selectedCategory == 'Managers'
                              ? Colors.amber[800] // Highlighted text color
                              : Colors.white, // Default text color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01),
                        height: 3,
                        width: screenWidth * 0.4,
                        color: selectedCategory == 'Managers'
                            ? Colors.amber[800] // Highlighted line color
                            : Colors.white
                                .withOpacity(0.4), // Default line color
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => _onCategorySelected('Employees'),
                  child: Column(
                    children: [
                      Text(
                        'שליח', // Employee
                        style: TextStyle(
                          fontSize: 18,
                          color: selectedCategory == 'Employees'
                              ? Colors.amber[800] // Highlighted text color
                              : Colors.white, // Default text color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01),
                        height: 3,
                        width: screenWidth * 0.4,
                        color: selectedCategory == 'Employees'
                            ? Colors.amber[800] // Highlighted line color
                            : Colors.white
                                .withOpacity(0.4), // Default line color
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  // Manager Requests
                  _buildRequestList(
                      'מנהל', _waitingManagersStream, 'WaitingManagers'),
                  // Employee Requests
                  _buildRequestList(
                      'שליח', _waitingEmployeesStream, 'WaitingEmployees'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
