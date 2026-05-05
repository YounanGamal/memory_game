import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_game/controllers/theme_controller.dart';

import '../../controllers/progression_controller.dart';
import '../../core/enums/game_enums.dart';
import '../../theme/app_colors.dart';
import '../level_card.dart';
import 'mode_selector.dart';
import 'player_info_bar.dart';

class LevelsTab extends StatelessWidget {
  final GameMode selectedMode;
  final ValueChanged<GameMode> onModeChanged;
  final ValueChanged<GameLevel> onStartLevel;

  const LevelsTab({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    required this.onStartLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progression = Get.find<ProgressionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PlayerInfoBar(),
          const SizedBox(height: 16),
          ModeSelector(selectedMode: selectedMode, onChanged: onModeChanged),
          const SizedBox(height: 18),
          Text(
            'Choose Level',
            style: GoogleFonts.outfit(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            // Explicitly subscribe to theme changes
            Get.find<ThemeController>().isDarkMode.value;
            
            final levels = selectedMode.levels;
            final unlockedLevel = progression.highestUnlockedFor(selectedMode);
            final starsByLevel = Map<String, int>.from(progression.bestStarsByLevel);

            return GridView.builder(
              itemCount: levels.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                final level = levels[index];
                return LevelCard(
                  level: level,
                  isUnlocked: level.number <= unlockedLevel,
                  isCurrent: level.number == unlockedLevel,
                  stars: starsByLevel[level.name] ?? 0,
                  onTap: () => onStartLevel(level),
                );
              },
            ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.04, end: 0);
          }),
        ],
      ),
    );
  }
}
