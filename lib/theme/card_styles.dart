import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import 'app_colors.dart';

class CardStyles {
  static const double borderRadius = 20.0;

  static CardThemeStyle get _style {
    if (Get.isRegistered<ThemeController>()) {
      return Get.find<ThemeController>().cardThemeStyle.value;
    }
    return CardThemeStyle.candyRush;
  }

  static List<Color> get themeColors {
    return switch (_style) {
      CardThemeStyle.candyRush => [
        AppColors.primaryPink,
        AppColors.primaryPurple,
      ],
      CardThemeStyle.sunsetGold => [
        const Color(0xFFFFB23F),
        const Color(0xFFFF5D8F),
      ],
    };
  }

  static Color get accentColor => switch (_style) {
    CardThemeStyle.candyRush => AppColors.primaryPink,
    CardThemeStyle.sunsetGold => const Color(0xFFFFB23F),
  };

  static BoxDecoration get closedDecoration => BoxDecoration(
    gradient: LinearGradient(
      colors: themeColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: accentColor.withValues(alpha: 0.22),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get openDecoration => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get matchedDecoration => BoxDecoration(
    gradient: LinearGradient(
      colors: themeColors.map((c) => c.withValues(alpha: 0.15)).toList(),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 2),
    boxShadow: [
      BoxShadow(
        color: accentColor.withValues(alpha: 0.12),
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ],
  );
}
