import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDeep = Color(0xFF4338CA);
  static const Color violet = Color(0xFF7C3AED);
  static const Color accent = Color(0xFF22D3EE);
  static const Color background = Color(0xFFF4F5F7);
  static const Color surface = Colors.white;
  static const Color field = Color(0xFFF0F1F4);
  static const Color hint = Color(0xFF98A2B3);
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);
  static const Color income = Color(0xFF059669);
  static const Color expense = Color(0xFFE11D48);
  static const Color scrim = Color(0x66000000);
  static const Color dividerLight = Color(0xFFEDF0F4);
  static const Color shadow = Color(0xFF98A2B3);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primary, primaryDeep],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryDeep, violet, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

BoxShadow appShadow({double alpha = 0.06, double blur = 16, double y = 6}) {
  return BoxShadow(
    color: AppColors.shadow.withValues(alpha: alpha),
    blurRadius: blur,
    offset: Offset(0, y),
  );
}