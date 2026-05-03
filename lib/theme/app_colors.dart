import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPink = Color(0xFFFF4DA6);
  static const Color primaryPurple = Color(0xFF9B4DFF);
  static const Color accentPink = Color(0xFFE91E63);
  static const Color background = Color(0xFFF5F5F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF222222);
  static const Color textGrey = Color(0xFF777777);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPink, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
