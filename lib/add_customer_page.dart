import 'package:flutter/material.dart';

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
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  List<Map<String, dynamic>> categories = [];

  static const availableCategories = ['תוספי מזון לבעלי חיים', 'קטגוריה אחרת'];
  static const productsByCategory = {
    'תוספי מזון לבעלי חיים': [
      'סידנית',
      'מלח סידן',
      'מלח',
      'DCP',
      'אוריאה',
      'חנקן בלתי חלבוני',
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
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
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
  String? selectedProduct;
  final weightController = TextEditingController();

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
                'בחר מוצר',
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
              itemCount: productsByCategory[category]?.length ?? 0,
              itemBuilder: (context, index) {
                final product = productsByCategory[category]![index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedProduct = product;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: selectedProduct == product
                            ? Colors.blue
                            : Colors.grey[700]!,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      product,
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
            Column(
              children: [
                if (selectedProduct != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'הזן משקל (טון)',
                        border: OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: selectedProduct == null ||
                              weightController.text.isEmpty
                          ? null
                          : () {
                              setState(() {
                                categories.add({
                                  'name': category,
                                  'products': [
                                    {
                                      'product': selectedProduct,
                                      'weight': weightController.text,
                                    },
                                  ],
                                });
                              });
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('שמור מוצר'),
                    ),
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
          ],
        );
      });
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('הוסף לקוח'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: firstNameController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'שם פרטי',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: lastNameController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'שם משפחה',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'אימייל',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'כתובת',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'טלפון',
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _showCategoryDialog,
                  child: const Text('הוסף קטגוריה'),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final customer = {
              'name': '${firstNameController.text} ${lastNameController.text}',
              'phone': phoneController.text,
              'email': emailController.text,
              'address': addressController.text,
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
