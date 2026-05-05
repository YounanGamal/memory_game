import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/theme_controller.dart';
import '../../theme/app_colors.dart';
import 'player_info_bar.dart';
import 'settings_tiles.dart';

class ThemesTab extends StatelessWidget {
  final ThemeController themeController;

  const ThemesTab({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
      children: [
        const PlayerInfoBar(),
        const SizedBox(height: 16),
        ToggleTile(
          icon: themeController.isDarkMode.value
              ? Icons.dark_mode_rounded
              : Icons.light_mode_rounded,
          label: 'Dark mode',
          value: themeController.isDarkMode.value,
          onChanged: (_) => themeController.toggleTheme(),
        ),
        const SizedBox(height: 12),
        CardStyleTile(
          style: CardThemeStyle.candyRush,
          colors: [AppColors.primaryPink, AppColors.primaryPurple],
          isSelected: themeController.cardThemeStyle.value == CardThemeStyle.candyRush,
          onTap: () => themeController.setCardTheme(CardThemeStyle.candyRush),
        ),
        const SizedBox(height: 12),
        CardStyleTile(
          style: CardThemeStyle.sunsetGold,
          colors: const [Color(0xFFFFB23F), Color(0xFFFF5D8F)],
          isSelected: themeController.cardThemeStyle.value == CardThemeStyle.sunsetGold,
          onTap: () => themeController.setCardTheme(CardThemeStyle.sunsetGold),
        ),
      ],
    );
  }
}
