import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google fonts package

// Terms of Service page
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            height: screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/image1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color.fromARGB(255, 57, 51, 42).withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // White frame coming up from the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.80, // Adjust height as needed
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.1),
                  topRight: Radius.circular(screenWidth * 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Center(
                      child: Text(
                        'תנאי שירות',
                        style: GoogleFonts.exo2(
                          color: const Color.fromARGB(255, 141, 126, 106),
                          fontSize: screenHeight * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Scrollable content for the Terms
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _termsOfServiceContent(), // Method to generate the terms content
                          style: GoogleFonts.exo2(
                            color: Colors.black.withOpacity(0.8),
                            fontSize:
                                screenHeight * 0.02, // Text size for content
                          ),
                          textAlign: TextAlign.justify, // Justify the text
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
          // Logo Positioned Above the Container
          Positioned(
            top: screenHeight * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo_zmitut.png', // Replace with your logo's asset path
                height: screenHeight * 0.1, // Adjust logo size as needed
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Back arrow button
          Positioned(
            top: screenHeight *
                0.05, // Positioning the arrow in the upper left corner
            left: screenWidth * 0.05,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous page
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method that provides the content of the terms
  String _termsOfServiceContent() {
    return '''
  ברוכים הבאים לצמיתות 81!

תנאים והגבלות אלה מתארים את הכללים והתקנות לשימוש באפליקציית צמיתות 81.

בגישה לאפליקציה זו, אנו מניחים שאתם מסכימים לתנאים ולהגבלות המפורטים כאן. אם אינכם מסכימים לתנאים ולהגבלות אלה, נא לא להמשיך להשתמש בצמיתות 81.

המונחים הבאים חלים על תנאי השירות, הצהרת הפרטיות וכל ההסכמים:

"לקוח", "אתם" ו"שלכם" מתייחסים למשתמש הנכנס לאפליקציה ומסכים לתנאים ולהגבלות של החברה.
"החברה", "אנחנו", "שלנו" ו"אותנו" מתייחסים לצמיתות 81.
"צד", "הצדדים" או "אנחנו" מתייחסים גם ללקוח וגם לחברה.

רישיון:

אלא אם צוין אחרת, צמיתות 81 ו/או מעניקי הרישיון שלה מחזיקים בזכויות הקניין הרוחני עבור כל החומר באפליקציה. כל הזכויות שמורות. אתם רשאים לגשת לחומר זה לשימוש אישי בלבד, בכפוף להגבלות המפורטות בתנאים אלו.

אין לבצע את הפעולות הבאות:

לפרסם מחדש חומר מצמיתות 81.
למכור, להשכיר או לתת רישיון משנה לחומר מצמיתות 81.
לשכפל, להעתיק או להעתיק חומר מצמיתות 81.
להפיץ מחדש תוכן מצמיתות 81.
מדיניות זו מתחילה מתאריך זה ואילך.

לפרטים נוספים, אתם מוזמנים לפנות אלינו ישירות בכתובת: support@zmitut81.com.

תודה על השימוש בצמיתות 81!
    ''';
  }
}
