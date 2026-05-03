import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class AppColors {
  static const Color _primaryPink = Color(0xFFFF4DA6);
  static const Color _primaryPurple = Color(0xFF7C5CFF);
  static const Color _accentPinkLight = Color(0xFFE91E63);
  static const Color _accentPinkDark = Color(0xFFFF7BBC);
  static const Color _backgroundLight = Color(0xFFF5F5F7);
  static const Color _backgroundDark = Color(0xFF101119);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1A1C27);
  static const Color _textDarkLight = Color(0xFF222222);
  static const Color _textDarkDark = Color(0xFFF5F6FA);
  static const Color _textGreyLight = Color(0xFF777777);
  static const Color _textGreyDark = Color(0xFFA8ADBD);

  static bool get _dark {
    if (Get.isRegistered<ThemeController>()) {
      return Get.find<ThemeController>().isDarkMode.value;
    }
    return Get.isDarkMode;
  }

  static Color get primaryPink => _primaryPink;
  static Color get primaryPurple => _primaryPurple;
  static Color get accentPink => _dark ? _accentPinkDark : _accentPinkLight;
  static Color get background => _dark ? _backgroundDark : _backgroundLight;
  static Color get white => _dark ? _surfaceDark : _surfaceLight;
  static Color get textDark => _dark ? _textDarkDark : _textDarkLight;
  static Color get textGrey => _dark ? _textGreyDark : _textGreyLight;
  static Color get border =>
      _dark ? const Color(0xFF2B2E3D) : const Color(0xFFE7E8EF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [_primaryPink, _primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get splashGradient => _dark
      ? const LinearGradient(
          colors: [Color(0xFF101119), Color(0xFF171426), Color(0xFF24163A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : primaryGradient;
}
