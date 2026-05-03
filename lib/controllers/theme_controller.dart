import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'is_dark_mode';

  final RxBool isDarkMode = false.obs;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    isDarkMode.value = preferences.getBool(_themeKey) ?? false;
    Get.changeThemeMode(themeMode);
  }

  Future<void> toggleTheme() async {
    isDarkMode.toggle();
    Get.changeThemeMode(themeMode);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themeKey, isDarkMode.value);
  }
}
