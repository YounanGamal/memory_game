import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_game/controllers/theme_controller.dart';

import '../../controllers/progression_controller.dart';
import '../../core/enums/game_enums.dart';
import '../../theme/app_colors.dart';
import 'player_info_bar.dart';
import 'progress_panel.dart';

class HomeTab extends StatelessWidget {
  final GameMode selectedMode;
  final VoidCallback onContinue;

  const HomeTab({
    super.key,
    required this.selectedMode,
    required this.onContinue,
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
          const SizedBox(height: 18),
          Obx(() {
            // Explicitly subscribe to theme changes
            Get.find<ThemeController>().isDarkMode.value;

            return ProgressPanel(
              unlocked: progression.highestUnlockedFor(selectedMode),
              total: selectedMode.levels.length,
              stars: progression.totalStars.value,
            );
          }),
          const SizedBox(height: 18),
          GestureDetector(
                onTap: onContinue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'CONTINUE',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 350.ms)
              .scale(begin: const Offset(0.96, 0.96)),
        ],
      ),
    );
  }
}
