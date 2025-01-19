import 'package:flutter/material.dart';
import 'dropdown_helpers.dart'; // Import the helper functions

class DateOfBirthDropdowns extends StatelessWidget {
  final String? selectedDay;
  final String? selectedMonth;
  final String? selectedYear;
  final Function(String?) onDayChanged;
  final Function(String?) onMonthChanged;
  final Function(String?) onYearChanged;
  final double screenWidth;

  const DateOfBirthDropdowns({
    super.key,
    required this.selectedDay,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Hebrew month names defined inside the widget
    final List<String> months = [
      'ינואר', // January
      'פברואר', // February
      'מרץ', // March
      'אפריל', // April
      'מאי', // May
      'יוני', // June
      'יולי', // July
      'אוגוסט', // August
      'ספטמבר', // September
      'אוקטובר', // October
      'נובמבר', // November
      'דצמבר', // December
    ];

    return Directionality(
      textDirection: TextDirection.rtl, // Set text direction to RTL
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          dropdownField(
            label: 'יום', // Hebrew for "Day"
            start: 1,
            end: 31,
            currentValue: selectedDay,
            onChanged: onDayChanged,
            screenWidth: screenWidth,
          ),
          dropdownFieldFromList(
            label: 'חודש', // Hebrew for "Month"
            items: months,
            currentValue: selectedMonth,
            onChanged: onMonthChanged,
            screenWidth: screenWidth,
          ),
          dropdownField(
            label: 'שנה', // Hebrew for "Year"
            start: 1930,
            end: DateTime.now().year,
            currentValue: selectedYear,
            onChanged: onYearChanged,
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }
}
