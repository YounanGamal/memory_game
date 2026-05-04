import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CardThemeStyle {
  candyRush(label: 'Candy Rush', description: 'Pink and purple card gradient.'),
  sunsetGold(
    label: 'Sunset Gold',
    description: 'Warm orange and pink card gradient.',
  );

  final String label;
  final String description;

  const CardThemeStyle({required this.label, required this.description});
}

class ThemeController extends GetxController {
  static const String _themeKey = 'is_dark_mode';
  static const String _cardThemeKey = 'card_theme_style';

  final RxBool isDarkMode = false.obs;
  final Rx<CardThemeStyle> cardThemeStyle = CardThemeStyle.candyRush.obs;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    isDarkMode.value = preferences.getBool(_themeKey) ?? false;
    final savedCardTheme = preferences.getString(_cardThemeKey);
    cardThemeStyle.value = CardThemeStyle.values.firstWhere(
      (style) => style.name == savedCardTheme,
      orElse: () => CardThemeStyle.candyRush,
    );
    Get.changeThemeMode(themeMode);
  }

  Future<void> toggleTheme() async {
    isDarkMode.toggle();
    Get.changeThemeMode(themeMode);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themeKey, isDarkMode.value);
  }

  Future<void> setCardTheme(CardThemeStyle style) async {
    cardThemeStyle.value = style;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_cardThemeKey, style.name);
  }
}
