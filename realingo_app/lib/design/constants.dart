import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StandardSizes {
  static const double medium = 24;
}

class StandardColors {
  static const Color brandBlue = Color(0xFF1696F7);
  static const Color white = Colors.white;
}

class StandardFonts {
  static TextStyle bigFunny =
      GoogleFonts.indieFlower(fontSize: 32, fontWeight: FontWeight.w900, color: StandardColors.brandBlue);

  static TextStyle bigFunnyWhite = GoogleFonts.indieFlower(fontSize: 32, fontWeight: FontWeight.w900);

  static TextStyle wordItem = GoogleFonts.karla();
  static TextStyle button = GoogleFonts.karla(fontSize: 32);
}
