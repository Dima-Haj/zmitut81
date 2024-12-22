import 'package:cloud_firestore/cloud_firestore.dart';
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
  int? selectedCategoryIndex;
  int? selectedProductIndex;

  List<String> weightTypes = ['ק"ג', 'טון']; // Weight options
  String selectedWeightType = 'ק"ג'; // Default selected value

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
                    color:
                        Color.fromARGB(255, 141, 126, 106), // Hint text color
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

  static const availableCategories = [
    'טיפול במים',
    'מינרלים',
    'תוספי מזון לבעלי חיים',
    'גינון ונוי',
    'בנייה'
  ];
  static const productsByCategory = {
    'טיפול במים': [
      'בזלת',
      'מלח ריכוך',
      'סיליקה',
      'קלציום קרבונט',
    ],
    'מינרלים': [
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
    'בנייה': [
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
        'מגורענים': [
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
              child: Directionality(
                textDirection: TextDirection.rtl, // Ensure RTL layout
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
                        if (mounted) {
                          setState(() {
                            selectedCategory = category;
                          });
                        }
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
                          textDirection:
                              TextDirection.rtl, // Text RTL alignment
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
    String? selectedProduct;
    String? selectedSubProduct;
    bool hasSubProducts = false;
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      final item = productList[index];
                      return GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setDialogState(() {
                              selectedProduct = item is Map
                                  ? item.keys.first
                                  : item.toString();
                              hasSubProducts = item is Map;
                              selectedSubProduct = null;
                            });
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedProduct ==
                                    (item is Map
                                        ? item.keys.first
                                        : item.toString())
                                ? Colors.blue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: Colors.grey[700]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            item is Map ? item.keys.first : item.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedProduct ==
                                      (item is Map
                                          ? item.keys.first
                                          : item.toString())
                                  ? Colors.white
                                  : Colors.black,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: selectedProduct == null
                          ? null
                          : () {
                              if (hasSubProducts) {
                                Navigator.pop(context);
                                final subCategoryName = selectedProduct!;
                                final subProducts = productList.firstWhere(
                                    (item) =>
                                        item is Map &&
                                        item.keys.first ==
                                            subCategoryName)[subCategoryName];
                                _showSubCategoryDialog(
                                    subCategoryName, subProducts, category);
                              } else {
                                Navigator.pop(context);
                                _showWeightAndPackagingDialog(
                                  category,
                                  selectedProduct!,
                                  '',
                                  [],
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('המשך'), // Unified text for both cases
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Reopen the parent product dialog
                        _showCategoryDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                      ),
                      child: const Text('חזרה'),
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

  void _showWeightAndPackagingDialog(String category, String product,
      String subProductname, List<dynamic> subProduct) {
    final TextEditingController weightController = TextEditingController();
    bool isPackaged = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'פרטי מוצר',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Directionality(
                    textDirection: TextDirection
                        .rtl, // Ensures label and text align to the right
                    child: Row(
                      children: [
                        // Weight Input Field
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'משקל', // Label text in Hebrew
                              alignLabelWithHint:
                                  true, // Keeps label aligned correctly
                              labelStyle: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),

                        // Spacing between TextField and Dropdown
                        // Dropdown for Weight Type
                        DropdownButton<String>(
                          value:
                              selectedWeightType, // The currently selected value
                          items: weightTypes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedWeightType =
                                  newValue!; // Update the selected value
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                        value: isPackaged,
                        onChanged: (value) {
                          setDialogState(() {
                            isPackaged = value;
                          });
                        },
                      ),
                      const Spacer(),
                      const Text(
                        'האם המוצר בשקיות?',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (weightController.text.isNotEmpty) {
                      Navigator.pop(context);
                      _saveProductDetails(
                          category,
                          product,
                          subProductname,
                          weightController.text,
                          selectedWeightType,
                          isPackaged);
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('שמור פרטים'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (subProductname == '') {
                      _showProductDialog(category);
                    } else {
                      _showSubCategoryDialog(product, subProduct, category);
                    }
                    // Logic to go back can be handled if needed
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('חזרה'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveProductDetails(String category, String product, String subProduct,
      String weight, String weightType, bool isPackaged) {
    setState(() {
      if (selectedCategoryIndex != null && selectedProductIndex != null) {
        // Update the existing product
        categories[selectedCategoryIndex!]['products']
            [selectedProductIndex!] = {
          'product': product,
          'Sub-Product': subProduct,
          'weight': double.tryParse(weight) ?? 0.0,
          'weightType': weightType,
          'isPackaged': isPackaged,
        };

        // Reset the selection
        selectedCategoryIndex = null;
        selectedProductIndex = null;
      } else {
        // Add a new product
        categories.add({
          'name': category,
          'products': [
            {
              'product': product,
              'Sub-Product': subProduct,
              'weight': double.tryParse(weight) ?? 0.0,
              'weightType': weightType,
              'isPackaged': isPackaged,
            }
          ],
        });
      }
    });
  }

  void _handleProductSelection(
      String categoryName, String productName, String subProductName) {
    // Retrieve the list of sub-products for the given category and product
    List<dynamic> subProducts = [];

    if (productsByCategory.containsKey(categoryName)) {
      final categoryProducts = productsByCategory[categoryName];

      if (categoryProducts is List) {
        for (var product in categoryProducts ?? []) {
          if (product is Map<String, List<dynamic>> &&
              product.containsKey(productName)) {
            subProducts = product[productName] ?? [];
            break;
          } else if (product is String && product == productName) {
            // If the product is directly a string, no sub-products are associated
            subProducts = [];
            break;
          }
        }
      }
    }

    // Call the dialog function with the filtered sub-products
    _showWeightAndPackagingDialog(
        categoryName, productName, subProductName, subProducts);
  }

  bool _areRequiredFieldsFilled() {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        addressCityController.text.isNotEmpty &&
        addressStreetController.text.isNotEmpty &&
        addressHouseNumberController.text.isNotEmpty;
  }

  void _showSubCategoryDialog(String subCategoryName, List<dynamic> subProducts,
      String parentCategory) {
    String? selectedSubProduct;

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
                    'בחר תת-מוצר',
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: subProducts.length,
                    itemBuilder: (context, index) {
                      final subProduct = subProducts[index];
                      return GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setDialogState(() {
                              selectedSubProduct = subProduct.toString();
                            });
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedSubProduct == subProduct
                                ? Colors.blue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: Colors.grey[700]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            subProduct,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedSubProduct == subProduct
                                  ? Colors.white
                                  : Colors.black,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: selectedSubProduct == null
                          ? null
                          : () {
                              Navigator.pop(context);
                              // Navigate to the weight and packaging dialog
                              _showWeightAndPackagingDialog(
                                  parentCategory,
                                  subCategoryName,
                                  selectedSubProduct!,
                                  subProducts);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('המשך'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Reopen the parent product dialog
                        _showProductDialog(parentCategory);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                      ),
                      child: const Text('חזרה'),
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
                            keyboardType:
                                TextInputType.number, // Set numeric keyboard
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
                                      if (product['Sub-Product'] != '')
                                        Text(
                                            'תת-מוצר: ${product['Sub-Product']}'),
                                      Text(
                                        'משקל: ${product['weight']} ${product['weightType']}',
                                      ),
                                      Text(
                                          'שקיות: ${product['isPackaged'] == true ? 'כן' : 'לא'}'),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        setState(() {
                                          selectedCategoryIndex =
                                              index; // Index of the category
                                          selectedProductIndex =
                                              0; // Always editing the first product
                                        });
                                        _handleProductSelection(
                                          category['name'],
                                          product['product'],
                                          product['Sub-Product'],
                                        );
                                      },
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
          onPressed: _areRequiredFieldsFilled()
              ? () async {
                  try {
                    // Create client data
                    final clientData = {
                      'name':
                          '${firstNameController.text} ${lastNameController.text}',
                      'phone': phoneController.text,
                      'email': emailController.text,
                      'address':
                          "${addressCityController.text} ${addressStreetController.text} ${addressHouseNumberController.text}",
                    };

                    // Get a reference to Firestore
                    final firestore = FirebaseFirestore.instance;

                    // Add client document and get the document ID
                    final clientDoc =
                        await firestore.collection('clients').add(clientData);

                    // Add categories as sub-collection (orders)
                    for (var category in categories) {
                      await firestore
                          .collection('clients')
                          .doc(clientDoc.id)
                          .collection('orders')
                          .add(category);
                    }

                    // Notify the user and close the page
                    widget.onAddCustomer(clientData);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save client: $e')),
                    );
                  }
                }
              : null, // Disable button if fields are not filled
          backgroundColor: _areRequiredFieldsFilled()
              ? Colors.blue // Active button color
              : Colors.grey, // Disabled button color
          label: const Text('שמור לקוח'),
          icon: const Icon(Icons.save),
        ),
      ),
    );
  }
}
