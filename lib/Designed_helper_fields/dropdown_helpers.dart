import 'package:flutter/material.dart';

Widget dropdownField({
  required String label,
  required int start,
  required int end,
  required String? currentValue,
  required void Function(String?) onChanged,
  required double screenWidth,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(screenWidth * 0.05),
      border: Border.all(
        color: const Color.fromARGB(255, 200, 200, 200),
        width: 1.0,
      ),
    ),
    child: DropdownButton<String>(
      value: currentValue,
      hint: Text(label),
      underline: const SizedBox(),
      items: [
        for (int i = start; i <= end; i++)
          DropdownMenuItem(value: i.toString(), child: Text(i.toString()))
      ],
      onChanged: onChanged,
    ),
  );
}

Widget dropdownFieldFromList({
  required String label,
  required List<String> items,
  required String? currentValue,
  required void Function(String?) onChanged,
  required double screenWidth,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(screenWidth * 0.05),
      border: Border.all(
        color: const Color.fromARGB(255, 200, 200, 200),
        width: 1.0,
      ),
    ),
    child: DropdownButton<String>(
      value: currentValue,
      hint: Text(label),
      underline: const SizedBox(),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    ),
  );
}
