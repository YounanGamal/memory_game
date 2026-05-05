import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memory_game/controllers/theme_controller.dart';

import '../../controllers/progression_controller.dart';
import '../../core/enums/game_enums.dart';
import 'player_info_bar.dart';
import 'settings_tiles.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final progression = Get.find<ProgressionController>();

    return Obx(
      () {
        // Explicitly subscribe to theme changes
        Get.find<ThemeController>().isDarkMode.value;
        
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
          children: [
            const PlayerInfoBar(),
            const SizedBox(height: 16),
            StatTile(icon: Icons.emoji_events_rounded, label: 'Wins', value: '${progression.wins.value}'),
            StatTile(icon: Icons.star_rounded, label: 'Total stars', value: '${progression.totalStars.value}'),
            StatTile(icon: Icons.sports_score_rounded, label: 'Best score', value: '${progression.bestScore.value}'),
            StatTile(icon: Icons.favorite_rounded, label: 'Perfect wins', value: '${progression.perfectWins.value}'),
            StatTile(
              icon: Icons.grid_view_rounded,
              label: 'Classic levels',
              value: '${progression.highestUnlockedFor(GameMode.classic)}/${GameMode.classic.levels.length}',
            ),
            StatTile(
              icon: Icons.timer_rounded,
              label: 'Time Attack levels',
              value: '${progression.highestUnlockedFor(GameMode.timeAttack)}/${GameMode.timeAttack.levels.length}',
            ),
          ],
        );
      },
    );
  }
}
