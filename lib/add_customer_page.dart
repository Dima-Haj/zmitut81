import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as time;

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
      ' בזלת',
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
      'קררה',
      'סומסומון',
      'מיקרו',
    ],
    'בנייה': [
      {
        'מוזאיקה - טראצו': [
          'בזלת',
          'ברק',
          'פרלוט',
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
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Rounded corners
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 194, 177,
                    156), // Change this to your desired background color
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Center(
                        child: const Text(
                          'בחר קטגוריה',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black, // Title text color
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
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
                                borderRadius: BorderRadius.circular(28.0),
                                border: Border.all(
                                  color: selectedCategory == category
                                      ? Colors.blue
                                      : const Color.fromARGB(255, 134, 118, 98),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 67, 67, 67)
                                        .withOpacity(0.5), // Shadow color
                                    spreadRadius: 1, // Spread of the shadow
                                    blurRadius: 3, // Blur effect
                                    offset: const Offset(
                                        0, 3), // Position of the shadow
                                  ),
                                ],
                              ),
                              child: Text(
                                category,
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
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
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
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
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showProductDialog(String category) {
    String? selectedProduct;
    bool hasSubProducts = false;
    final List<dynamic> productList = productsByCategory[category] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Rounded corners
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      255, 194, 177, 156), // Background color
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Center(
                          child: const Text(
                            'בחר מוצר',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black, // Title text color
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
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
                                  });
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28.0),
                                  border: Border.all(
                                    color: selectedProduct ==
                                            (item is Map
                                                ? item.keys.first
                                                : item.toString())
                                        ? Colors
                                            .blue // Only border changes color
                                        : const Color.fromARGB(
                                            255, 134, 118, 98),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(255, 67, 67, 67)
                                              .withOpacity(0.5), // Shadow color
                                      spreadRadius: 1, // Spread of the shadow
                                      blurRadius: 3, // Blur effect
                                      offset: const Offset(
                                          0, 3), // Position of the shadow
                                    ),
                                  ],
                                ),
                                child: Text(
                                  item is Map
                                      ? item.keys.first
                                      : item.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black, // Text remains black
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Continue button moved to the left
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
                                                    subCategoryName)[
                                        subCategoryName];
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
                          child: const Text('המשך'),
                        ),
                        // Back button moved to the right
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWeightAndPackagingDialog(String category, String product,
      String subProductName, List<dynamic> subProduct) {
    final TextEditingController weightController = TextEditingController();
    final TextEditingController otherPackagingController =
        TextEditingController();
    String? selectedPackaging = 'Bags'; // Default to "Bags"
    bool showOtherPackaging = false;
    String? selectedSize; // To store the selected size

    // Define sizes for each product or sub-product
    final Map<String, List<String>> productSizes = {
      'בזלת': ['פוליה: 16-19', 'עדס: 9-16', 'אחר: 2.5-9', 'סומסומון: 1.4-2.5'],
      'ברק': ['פוליה: 16-25', 'עדס: 9-16', 'אחר: 2.5-9', 'סומסומון: 1.4-2.5'],
      'פרלטו': [
        '32-45',
        '22-32',
        '6-19',
      ],
      'קררה': [
        '30-40',
        '22-30',
        '18-22',
        '12-18',
        '9-12',
        '4-9',
      ],
      'מלאן - גיר בניה': [
        '0.3-0.6',
        '0-0.3',
      ],
      'סומסומון': [
        '1.4-2.3',
      ],
      'מיקרו': [
        '0.6-1.4',
      ],
      'פיקסל': [
        '0.3-0.6',
      ],
      'מצע לגני משחקים': [
        'גרגילון 1: 0.7-2.0',
        'גרגילון 2: 6.3-2.0',
        'גרגילון 3: 0.3-1.4',
        'גרגילון 4: 0.3-2.0',
      ],
      'סידנית': [
        '2.5-4.75',
        '1.4-2.5',
        '0.6-1.4',
        '0-0.6',
        '0-1.5',
      ],
      'מלח': [
        'Fine Grade 0-0.8',
        'Coarse Grade 0.8-2',
        'Granular Grade 1-4',
      ],
      'דלומיט': [
        '3-6',
        '1.4-2.5',
        '0.6-1.4',
        '0-1.4',
        '0-0.6',
      ],
      'קלציום קרבונט': [
        '2.5-4.75',
        '1.4-2.5',
        '0.6-1.4',
        '0.3-1.4',
        '0-0.6',
      ],
      'סיליקה': [
        '3-6',
        '2-3',
        '0.6-1',
      ],
      'מלח ריכוך': [
        'Fine Grade 0-0.8',
        'Coarse Grade 0.8-2',
        'Granular Grade 1-4',
      ],
      ' בזלת': [
        '2.5-4.75',
        '1.4-2.5',
        '0.6-1.4',
        '0.3-0.6',
      ],

      // Add more product and sub-product sizes as needed
    };

    // Determine which name to use for sizes
    final String sizeKey = subProductName.isNotEmpty ? subProductName : product;

    // Get sizes for the selected product or sub-product
    final List<String> sizes = productSizes[sizeKey] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 194, 177, 156),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Center(
                          child: const Text(
                            'פרטי מוצר',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Size Selection
                    if (sizes.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: DropdownButton<String>(
                              value: selectedSize,
                              hint: const Text('(mm) בחר גודל'),
                              items: sizes.map((size) {
                                return DropdownMenuItem<String>(
                                  value: size,
                                  child: Text(size),
                                );
                              }).toList(),
                              onChanged: (String? newSize) {
                                setDialogState(() {
                                  selectedSize = newSize;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    const SizedBox(height: 16),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'משקל',
                                alignLabelWithHint: true,
                                labelStyle: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: selectedWeightType,
                            items: ['ק"ג', 'טון'].map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setDialogState(() {
                                selectedWeightType = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'Bags',
                            groupValue: selectedPackaging,
                            title: const Text('שקיות'),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedPackaging = value!;
                                showOtherPackaging = false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'Other',
                            groupValue: selectedPackaging,
                            title: const Text('אחר'),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedPackaging = value!;
                                showOtherPackaging = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (showOtherPackaging)
                      TextField(
                        controller: otherPackagingController,
                        decoration: const InputDecoration(
                          labelText: 'פרטי אריזה',
                          hintText: 'הכנס פרטי אריזה מותאמים אישית',
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (weightController.text.isNotEmpty &&
                                ((sizes.isNotEmpty && selectedSize != null) ||
                                    sizes.isEmpty)) {
                              Navigator.pop(context);
                              _saveProductDetails(
                                category,
                                product,
                                subProductName,
                                weightController.text,
                                selectedWeightType,
                                selectedPackaging == 'Bags',
                                showOtherPackaging
                                    ? otherPackagingController.text
                                    : 'Bags',
                                sizes.isNotEmpty
                                    ? selectedSize!
                                    : null, // Pass selectedSize if sizes is not empty, otherwise null
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('שמור פרטים'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (subProductName == '') {
                              _showProductDialog(category);
                            } else {
                              _showSubCategoryDialog(
                                product,
                                subProduct,
                                category,
                              );
                            }
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
              ),
            );
          },
        );
      },
    );
  }

  void _saveProductDetails(
      String category,
      String product,
      String subProduct,
      String weight,
      String weightType,
      bool isPackaged,
      String packagingDetails,
      String? size) {
    setState(() {
      if (selectedCategoryIndex != null && selectedProductIndex != null) {
        final formattedDate =
            time.DateFormat('dd-MM-yyyy').format(DateTime.now());
        // Update the existing product
        categories[selectedCategoryIndex!]['products']
            [selectedProductIndex!] = {
          'product': product,
          if (subProduct != '') 'Sub-Product': subProduct,
          'weight': double.tryParse(weight) ?? 0.0,
          'weightType': weightType,
          'isPackaged': isPackaged,
          if (packagingDetails != '') 'packagingDetails': packagingDetails,
          if (size != null) 'size': size, // Save the selected size
          'Date': formattedDate,
        };

        // Reset the selection
        selectedCategoryIndex = null;
        selectedProductIndex = null;
      } else {
        // Add a new product
        final formattedDate =
            time.DateFormat('dd-MM-yyyy').format(DateTime.now());
        categories.add({
          'name': category,
          'product': product,
          if (subProduct != '') 'Sub-Product': subProduct,
          'weight': double.tryParse(weight) ?? 0.0,
          'weightType': weightType,
          'isPackaged': isPackaged,
          'packagingDetails': isPackaged ? 'Bags' : packagingDetails,
          if (size != null) 'size': size, // Save the selected size
          'Date': formattedDate,
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
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Rounded corners
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      255, 194, 177, 156), // Background color
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Center(
                          child: const Text(
                            'בחר תת-מוצר',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black, // Title text color
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border.all(
                                    color: selectedSubProduct == subProduct
                                        ? Colors.blue // Border changes to blue
                                        : const Color.fromARGB(
                                            255, 134, 118, 98),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(255, 67, 67, 67)
                                              .withOpacity(0.5), // Shadow color
                                      spreadRadius: 1, // Spread of the shadow
                                      blurRadius: 3, // Blur effect
                                      offset: const Offset(
                                          0, 3), // Position of the shadow
                                    ),
                                  ],
                                ),
                                child: Text(
                                  subProduct,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black, // Text remains black
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Continue button moved to the left
                        ElevatedButton(
                          onPressed: selectedSubProduct == null
                              ? null
                              : () {
                                  Navigator.pop(context);
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
                        // Back button moved to the right
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
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
                ),
              ),
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
                  mainAxisSize: MainAxisSize
                      .min, // Add this line to prevent Column expansion
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
                                      Text('מוצר: ${category['product']}'),
                                      if (category['Sub-Product'] != '')
                                        Text(
                                            'תת-מוצר: ${category['Sub-Product']}'),
                                      Text(
                                        'משקל: ${category['weight']} ${category['weightType']}',
                                      ),
                                      Text(
                                          'שקיות: ${category['isPackaged'] == true ? 'כן' : 'לא'}'),
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
                                          category['product'],
                                          category['Sub-Product'],
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
