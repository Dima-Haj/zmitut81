import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController firstPartController;
  final TextEditingController secondPartController;

  const PhoneField({
    super.key,
    required this.firstPartController,
    required this.secondPartController,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
              border: Border.all(
                color: const Color.fromARGB(255, 141, 126, 106),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.phone,
                    size: 16, color: const Color.fromARGB(255, 141, 126, 106)),
                const SizedBox(width: 2),
                const Text(
                  '05',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                Expanded(
                  child: TextField(
                    controller: firstPartController,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.exo2(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    decoration: const InputDecoration(
                      counterText: "",
                      hintText: 'X',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      if (value.length == 1) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        const Text('-'),
        SizedBox(width: screenWidth * 0.01),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
              border: Border.all(
                color: const Color.fromARGB(255, 141, 126, 106),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: secondPartController,
              maxLength: 7,
              keyboardType: TextInputType.number,
              style: GoogleFonts.exo2(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              decoration: const InputDecoration(
                counterText: "",
                hintText: 'XXX-XXXX',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
