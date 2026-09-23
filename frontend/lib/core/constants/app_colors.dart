import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0E33F3);
  static const Color accent = Color(0xFF2FDAFF);
  static const Color background = Color(0xFFDCDFE3);
  static const Color surface = Colors.white;
  static const Color field = Color(0xFFF5F6F7);
  static const Color hint = Color(0xFF9BA1A8);
  static const Color textPrimary = Color(0xFF12141A);
  static const Color textSecondary = Color(0xFF5A6472);
  static const Color income = Color(0xFF16A34A);
  static const Color expense = Color(0xFFDC2626);
  static const Color scrim = Color(0x66000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
