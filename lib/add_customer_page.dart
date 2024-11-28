import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCustomerPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddCustomer;

  const AddCustomerPage({super.key, required this.onAddCustomer});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final addressCityController = TextEditingController();
  final addressStreetController = TextEditingController();
  final addressHouseNumberController = TextEditingController();
  final phoneController = TextEditingController();

  final firstNameFocusNode = FocusNode();
  final lastNameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final addressCityFocusNode = FocusNode();
  final addressStreetFocusNode = FocusNode();
  final addressHouseNumberFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    addressCityController.dispose();
    addressHouseNumberController.dispose();
    addressStreetController.dispose();
    phoneController.dispose();

    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    addressCityFocusNode.dispose();
    addressHouseNumberFocusNode.dispose();
    addressStreetFocusNode.dispose();
    phoneFocusNode.dispose();

    super.dispose();
  }

  Widget buildTextField(
    String hintText,
    IconData icon,
    double screenWidth, {
    bool obscureText = false,
    required FocusNode focusNode,
    required bool isHovered,
    required bool isFocused,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text, // Default to text
    List<TextInputFormatter>? inputFormatters, // Optional input formatters
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(
          color: const Color.fromARGB(255, 141, 126, 106), // Border color
          width: 1.0, // Border width
        ),
        boxShadow: isHovered || isFocused
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 141, 126, 106)),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType, // Use the provided keyboard type
              inputFormatters: inputFormatters, // Apply input formatters
              style: GoogleFonts.exo2(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.exo2(
                  textStyle: const TextStyle(
                    color: Color.fromARGB(255, 141, 126, 106), // Hint text color
                  ),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }


  List<Map<String, dynamic>> categories = [];

  static const availableCategories = ['טיפול במים', 'מינרלים', 'תוספי מזון לבעלי חיים', 'גינון ונוי', 'בנייה'];
  static const productsByCategory = {
    'טיפול במים':[
      'בזלת',
      'מלח ריכוך',
      'סיליקה',
      'קלציום קרבונט',
    ],
    'מינירלים':[
      'דלומיט',
      'מלח',
      'סיליקה',
      'קלציום קרבונט',
    ],
    'תוספי מזון לבעלי חיים': [
      'סידנית',
      'מלח סידן',
      'מלח',
      'DCP',
      'אוריאה',
      'חנקן בלתי חלבוני',
    ],
    'גינון ונוי': [
      'מצע לגני משחקים',
      'ברק',
      'אדום',
      'ירקרק',
      'צהוב',
      'ערד',
      'קררה',
      'סומסומון',
      'מיקרו',
      'פתיתי זכוכית',
    ],
    'בנייה':[
        {
          'מוזאיקה - טראצו': [
          'אדום',
          'בזלת',
          'ברק',
          'ירקרק',
          'ערד',
          'פרלוט',
          'צהוב',
          'קררה',
        ],
      },
       'מלאן - גיר בניה',
       {
        'מגורענים':[
          'סומסומון',
          'מיקרו',
          'פיקסל',
        ],
       },
       'זכוכית ממוחזרת',
    ],
  };

  void _showCategoryDialog() {
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'בחר קטגוריה',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: availableCategories.length,
                itemBuilder: (context, index) {
                  final category = availableCategories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: selectedCategory == category
                              ? Colors.blue
                              : Colors.grey[700]!,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        category,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: selectedCategory == null
                    ? null
                    : () {
                        Navigator.pop(context);
                        _showProductDialog(selectedCategory!);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('המשך'),
              ),
            ],
          );
        });
      },
    );
  }

void _showProductDialog(String category) {
  String? selectedSubCategory;
  final List<dynamic> productList = productsByCategory[category] ?? [];
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'בחר מוצר',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    final item = productList[index];
                    if (item is Map) {
                      // Render sub-category button
                      final subCategoryName = item.keys.first;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Close current dialog
                          _showSubCategoryDialog(subCategoryName, item[subCategoryName]);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: Colors.grey[700]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            subCategoryName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Render product button
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedSubCategory = item.toString();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedSubCategory == item.toString() ? Colors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: Colors.grey[700]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            item.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedSubCategory == item.toString() ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: selectedSubCategory == null
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('המשך'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showSubCategoryDialog(String subCategory, List<String> items) {
  String? selectedItem;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  subCategory,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final product = items[index];
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedItem = product;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedItem == product ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: Colors.grey[700]!,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          product,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedItem == product ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            actions: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: selectedItem == null
                            ? null
                            : () {
                                Navigator.pop(context);
                                // Perform any save action here
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('שמור מוצר'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the current dialog
                          _showProductDialog("בנייה"); // Adjust to the parent category dynamically
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                        ),
                        child: const Text('חזרה'),
                      ),
                    ],
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




  @override
  Widget build(BuildContext context) {
return Directionality(
  textDirection: TextDirection.rtl, // Keep the text direction RTL
  child: Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false, // Disable default leading behavior
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread widgets
        children: [
          const Text(
            'הוסף לקוח',
            textAlign: TextAlign.right, // Align the text to the right
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward), // Back arrow icon
            onPressed: () {
              Navigator.pop(context); // Navigate back
            },
          ),
        ],
      ),
    ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/image1.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color.fromRGBO(57, 51, 42, 0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.15,
                  left: 16,
                  right: 16,
                  bottom: 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(
                            'שם פרטי',
                            Icons.person,
                            MediaQuery.of(context).size.width,
                            focusNode: firstNameFocusNode,
                            isHovered: false,
                            isFocused: firstNameFocusNode.hasFocus,
                            controller: firstNameController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildTextField(
                            'שם משפחה',
                            Icons.person_outline,
                            MediaQuery.of(context).size.width,
                            focusNode: lastNameFocusNode,
                            isHovered: false,
                            isFocused: lastNameFocusNode.hasFocus,
                            controller: lastNameController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      'אימייל',
                      Icons.email,
                      MediaQuery.of(context).size.width,
                      focusNode: emailFocusNode,
                      isHovered: false,
                      isFocused: emailFocusNode.hasFocus,
                      controller: emailController,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(
                            'עיר',
                            Icons.location_city,
                            MediaQuery.of(context).size.width,
                            focusNode: addressCityFocusNode,
                            isHovered: false,
                            isFocused: addressCityFocusNode.hasFocus,
                            controller: addressCityController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: buildTextField(
                            'רחוב',
                            Icons.directions,
                            MediaQuery.of(context).size.width,
                            focusNode: addressStreetFocusNode,
                            isHovered: false,
                            isFocused: addressStreetFocusNode.hasFocus,
                            controller: addressStreetController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: buildTextField(
                            'בית',
                            Icons.home,
                            MediaQuery.of(context).size.width,
                            focusNode: addressHouseNumberFocusNode,
                            isHovered: false,
                            isFocused: addressHouseNumberFocusNode.hasFocus,
                            controller: addressHouseNumberController,
                            keyboardType: TextInputType.number, // Set numeric keyboard

                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      'טלפון',
                      Icons.phone,
                      MediaQuery.of(context).size.width,
                      focusNode: phoneFocusNode,
                      isHovered: false,
                      isFocused: phoneFocusNode.hasFocus,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: _showCategoryDialog,
                        child: const Text('הוסף קטגוריה'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (categories.isNotEmpty)
                      Column(
                        children: List.generate(categories.length, (index) {
                          final category = categories[index];
                          final product = category['products'][0];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'קטגוריה: ${category['name']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('מוצר: ${product['product']}'),
                                      Text('משקל (טון): ${product['weight']}'),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed:
                                          () {}, // Add edit functionality
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          categories.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final customer = {
              'name': '${firstNameController.text} ${lastNameController.text}',
              'phone': phoneController.text,
              'email': emailController.text,
              'address': addressCityController.text+" "+addressStreetController.text+" "+addressHouseNumberController.text,
              'categories': categories,
            };
            widget.onAddCustomer(customer);
            Navigator.pop(context);
          },
          label: const Text('שמור לקוח'),
          icon: const Icon(Icons.save),
        ),
      ),
    );
  }
}
