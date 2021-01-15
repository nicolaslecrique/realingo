import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StandardSizes {
  static const double medium = 24;
}

class StandardColors {
  static const Color brandBlue = Color(0xFF1696F7);
  static const Color accentColor = Color(0xFFF76516);
  static const Color white = Colors.white;

  static Map<int, Color> colorCodes = {
    50: Color.fromRGBO(87, 180, 250, .1),
    100: Color.fromRGBO(87, 180, 250, .2),
    200: Color.fromRGBO(87, 180, 250, .3),
    300: Color.fromRGBO(87, 180, 250, .4),
    400: Color.fromRGBO(87, 180, 250, .5),
    500: Color.fromRGBO(87, 180, 250, .6),
    600: Color.fromRGBO(87, 180, 250, .7),
    700: Color.fromRGBO(87, 180, 250, .8),
    800: Color.fromRGBO(87, 180, 250, .9),
    900: Color.fromRGBO(87, 180, 250, 1),
  };

  static MaterialColor themeColor = MaterialColor(0xFF57B4FA, colorCodes);

  static Color correct = Colors.green;
  static Color incorrect = Colors.red;
}

class StandardFonts {
  static TextStyle bigFunny =
      GoogleFonts.indieFlower(fontSize: 32, fontWeight: FontWeight.w900, color: StandardColors.brandBlue);

  static TextStyle bigFunnyWhite =
      GoogleFonts.indieFlower(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white);

  static TextStyle wordItem = GoogleFonts.karla();
  static TextStyle button = bigFunnyWhite;
}
